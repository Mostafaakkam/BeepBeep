const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');

const validateRegistrationData = (data) => {
  const errors = [];

  if (!data.name || typeof data.name !== 'string' || data.name.trim().length < 2) {
    errors.push('Name must be at least 2 characters');
  }

  if (!data.phone || typeof data.phone !== 'string' || !/^\+?[\d\s-]{10,}$/.test(data.phone.trim())) {
    errors.push('Invalid phone number');
  }

  if (!data.email || typeof data.email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email.trim())) {
    errors.push('Invalid email address');
  }

  if (!data.password || typeof data.password !== 'string' || data.password.length < 6) {
    errors.push('Password must be at least 6 characters');
  }

  return errors;
};

const register = async (userData) => {
  const validationErrors = validateRegistrationData(userData);
  if (validationErrors.length > 0) {
    const error = new Error('Validation failed');
    error.validationErrors = validationErrors;
    throw error;
  }

  const { name, phone, email, password } = userData;
  const trimmedData = {
    name: name.trim(),
    phone: phone.trim(),
    email: email.trim().toLowerCase(),
    password
  };

  const existingUserByEmail = await userRepository.findByEmail(trimmedData.email);
  if (existingUserByEmail) {
    const error = new Error('Email already registered');
    error.code = 'DUPLICATE_EMAIL';
    throw error;
  }

  const existingUserByPhone = await userRepository.findByPhone(trimmedData.phone);
  if (existingUserByPhone) {
    const error = new Error('Phone number already registered');
    error.code = 'DUPLICATE_PHONE';
    throw error;
  }

  const hashedPassword = await bcrypt.hash(trimmedData.password, 10);

  const newUser = await userRepository.create({
    name: trimmedData.name,
    phone: trimmedData.phone,
    email: trimmedData.email,
    password: hashedPassword,
    role: 'customer'
  });

  return newUser;
};

const validateLoginData = (data) => {
  const errors = [];

  if (!data.email || typeof data.email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email.trim())) {
    errors.push('Invalid email address');
  }

  if (!data.password || typeof data.password !== 'string' || data.password.length === 0) {
    errors.push('Password is required');
  }

  return errors;
};

const login = async (loginData) => {
  const validationErrors = validateLoginData(loginData);
  if (validationErrors.length > 0) {
    const error = new Error('Validation failed');
    error.validationErrors = validationErrors;
    throw error;
  }

  const { email, password } = loginData;
  const trimmedEmail = email.trim().toLowerCase();

  const user = await userRepository.findByEmailWithPassword(trimmedEmail);
  
  if (!user) {
    const error = new Error('Invalid credentials');
    error.code = 'INVALID_CREDENTIALS';
    throw error;
  }

  const isPasswordValid = await bcrypt.compare(password, user.password);
  
  if (!isPasswordValid) {
    const error = new Error('Invalid credentials');
    error.code = 'INVALID_CREDENTIALS';
    throw error;
  }

  const token = jwt.sign(
    { 
      userId: user.id, 
      role: user.role 
    },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );

  const { password: _, ...userWithoutPassword } = user;

  return {
    user: userWithoutPassword,
    token
  };
};

// Store Owner Dashboard: GET /api/auth/me used to just echo back
// req.user.role, which is the JWT's role claim -- valid for up to 7 days,
// so a role change (e.g. promotion to store_owner) would not be reflected
// here until the token was reissued. This is the exact staleness problem
// requireRole() (authorizationMiddleware.js) already solves for gated
// routes; getCurrentUser applies the same fix to this one, since the
// Flutter app now uses it on session restore to decide whether to show the
// Store Owner Dashboard entry point -- "determine the user's current role
// from the backend, do not trust a client-supplied role" only holds if this
// endpoint itself is DB-fresh.
const getCurrentUser = async (userId) => {
  const user = await userRepository.findById(userId);
  if (!user) {
    const error = new Error('User not found');
    error.code = 'USER_NOT_FOUND';
    throw error;
  }
  return { userId: user.id, role: user.role };
};

module.exports = {
  register,
  login,
  getCurrentUser
};
