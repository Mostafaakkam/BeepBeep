const authService = require('../services/authService');

const register = async (req, res) => {
  try {
    const user = await authService.register(req.body);
    
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        created_at: user.created_at
      }
    });
  } catch (error) {
    if (error.message === 'Validation failed') {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: error.validationErrors
      });
    }

    if (error.code === 'DUPLICATE_EMAIL') {
      return res.status(409).json({
        success: false,
        message: 'Email already registered'
      });
    }

    if (error.code === 'DUPLICATE_PHONE') {
      return res.status(409).json({
        success: false,
        message: 'Phone number already registered'
      });
    }

    console.error('Registration error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to register user'
    });
  }
};

const login = async (req, res) => {
  try {
    const { user, token } = await authService.login(req.body);
    
    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          role: user.role,
          created_at: user.created_at
        },
        token
      }
    });
  } catch (error) {
    if (error.message === 'Validation failed') {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: error.validationErrors
      });
    }

    if (error.code === 'INVALID_CREDENTIALS') {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    console.error('Login error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to login'
    });
  }
};

// Store Owner Dashboard: now returns the DB-verified current role (see
// authService.getCurrentUser) instead of the JWT's role claim, so a role
// change takes effect immediately here too -- same principle as
// requireRole(), applied to this read-only "who am I" endpoint. Response
// shape (`{userId, role}`) is unchanged.
const getMe = async (req, res) => {
  try {
    const currentUser = await authService.getCurrentUser(req.user.userId);

    res.status(200).json({
      success: true,
      message: 'Authenticated user retrieved',
      data: currentUser
    });
  } catch (error) {
    if (error.code === 'USER_NOT_FOUND') {
      return res.status(401).json({
        success: false,
        message: 'Authentication failed'
      });
    }

    console.error('Get me error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve user'
    });
  }
};

module.exports = {
  register,
  login,
  getMe
};
