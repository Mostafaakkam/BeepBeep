/**
 * authorizationMiddleware.js
 * ---------------------------------------------------------------------------
 * Reusable authorization middleware for the Store Ownership + Role-Based
 * Authorization + Single-Store Order feature.
 *
 * These are AUTHORIZATION checks (is this authenticated user allowed to do
 * this?), layered on top of the existing `authenticate` middleware in
 * authMiddleware.js, which only handles AUTHENTICATION (is this a valid
 * token?). Every middleware here assumes `authenticate` already ran and set
 * `req.user = { userId, role }`.
 *
 * Server-side verification, not client trust:
 *   - requireRole() re-fetches the user's CURRENT role from the `users`
 *     table instead of trusting the `role` claim embedded in the JWT. A JWT
 *     is valid for up to 7 days (see authService.js); if an admin changes a
 *     user's role after a token was issued, trusting the claim alone would
 *     let a demoted user keep elevated access, or a newly-promoted user wait
 *     up to 7 days for it to take effect. Re-checking against the database
 *     closes that window at the cost of one indexed lookup per gated
 *     request. This only runs on the new role-gated routes introduced by
 *     this feature -- it adds no overhead to any existing customer-facing
 *     route.
 *   - requireStoreOwnership() / requireProductOwnership() never trust a
 *     store/owner id supplied by the client. They resolve ownership purely
 *     from `req.params` (which resource is being acted on) and the
 *     database (who actually owns it) -- never from anything in the request
 *     body that claims to be an owner/user id.
 *
 * Admin bypass: both ownership middlewares let `role === 'admin'` through
 * regardless of actual ownership, so the same middleware stack already works
 * for a future admin dashboard without any rework.
 */

const userRepository = require('../repositories/userRepository');
const storeRepository = require('../repositories/storeRepository');
const productRepository = require('../repositories/productRepository');

/**
 * requireRole(...allowedRoles)
 * Must run after `authenticate`. Verifies the authenticated user's CURRENT
 * role (fetched fresh from the database) is one of `allowedRoles`. Refreshes
 * `req.user.role` in place with the verified value, so anything chained
 * after this (including requireStoreOwnership's admin bypass) uses the
 * verified role, not the original JWT claim.
 */
const requireRole = (...allowedRoles) => {
  return async (req, res, next) => {
    try {
      if (!req.user || !req.user.userId) {
        return res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
      }

      const user = await userRepository.findById(req.user.userId);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Authentication failed'
        });
      }

      // Refresh with the DB-verified role, not the (possibly stale) JWT claim.
      req.user.role = user.role;

      if (!allowedRoles.includes(user.role)) {
        return res.status(403).json({
          success: false,
          message: 'Insufficient permissions'
        });
      }

      next();
    } catch (error) {
      console.error('Role authorization error:', error.message);
      res.status(500).json({
        success: false,
        message: 'Authorization check failed'
      });
    }
  };
};

/**
 * requireStoreOwnership(paramName = 'storeId')
 * Must run after `authenticate` + `requireRole`. Resolves the target store
 * from `req.params[paramName]`, loads its `owner_id` server-side, and allows
 * the request only if the authenticated user owns that store, or has the
 * `admin` role (ownership bypass). Attaches `req.store = { id, ownerId }` on
 * success so controllers don't need to re-fetch it.
 */
const requireStoreOwnership = (paramName = 'storeId') => {
  return async (req, res, next) => {
    try {
      const storeId = parseInt(req.params[paramName], 10);
      if (!storeId || Number.isNaN(storeId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid store id'
        });
      }

      const ownerId = await storeRepository.findOwnerId(storeId);
      if (ownerId === undefined) {
        return res.status(404).json({
          success: false,
          message: 'Store not found'
        });
      }

      if (req.user.role === 'admin') {
        req.store = { id: storeId, ownerId };
        return next();
      }

      if (ownerId === null || ownerId !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'You do not have access to this store'
        });
      }

      req.store = { id: storeId, ownerId };
      next();
    } catch (error) {
      console.error('Store ownership authorization error:', error.message);
      res.status(500).json({
        success: false,
        message: 'Authorization check failed'
      });
    }
  };
};

/**
 * requireProductOwnership(paramName = 'id')
 * Same pattern as requireStoreOwnership, but resolves ownership transitively
 * via the product's store (product -> store.owner_id).
 *
 * Not mounted on any route yet -- no product-management endpoints are in
 * scope for this backend-foundation feature (Store Owner Dashboard/product
 * management UI are explicitly out of scope). Implemented and unit-tested
 * here so it's ready to attach to those routes when that work begins,
 * without needing new authorization infrastructure at that point.
 */
const requireProductOwnership = (paramName = 'id') => {
  return async (req, res, next) => {
    try {
      const productId = parseInt(req.params[paramName], 10);
      if (!productId || Number.isNaN(productId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid product id'
        });
      }

      const storeId = await productRepository.findStoreIdById(productId);
      if (storeId === undefined) {
        return res.status(404).json({
          success: false,
          message: 'Product not found'
        });
      }

      const ownerId = await storeRepository.findOwnerId(storeId);

      if (req.user.role === 'admin') {
        req.product = { id: productId, storeId };
        req.store = { id: storeId, ownerId };
        return next();
      }

      if (ownerId === null || ownerId !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'You do not have access to this product'
        });
      }

      req.product = { id: productId, storeId };
      req.store = { id: storeId, ownerId };
      next();
    } catch (error) {
      console.error('Product ownership authorization error:', error.message);
      res.status(500).json({
        success: false,
        message: 'Authorization check failed'
      });
    }
  };
};

module.exports = {
  requireRole,
  requireStoreOwnership,
  requireProductOwnership
};
