const request = require('supertest');
const app = require('../../src/app');

describe('API Endpoints', () => {
  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app).get('/health').expect(200);

      expect(response.body).toHaveProperty('status', 'OK');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('version');
    });
  });

  describe('GET /api/v1/users', () => {
    it('should return list of users', async () => {
      const response = await request(app).get('/api/v1/users').expect(200);

      expect(response.body).toHaveProperty('message', 'Users endpoint');
      expect(response.body).toHaveProperty('data');
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data).toHaveLength(2);
    });
  });

  describe('POST /api/v1/users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'Test User',
        email: 'test@example.com'
      };

      const response = await request(app).post('/api/v1/users').send(userData).expect(201);

      expect(response.body).toHaveProperty('message', 'User created successfully');
      expect(response.body.data).toHaveProperty('name', userData.name);
      expect(response.body.data).toHaveProperty('email', userData.email);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data).toHaveProperty('createdAt');
    });

    it('should return 400 if name is missing', async () => {
      const userData = {
        email: 'test@example.com'
      };

      const response = await request(app).post('/api/v1/users').send(userData).expect(400);

      expect(response.body).toHaveProperty('error', 'Name and email are required');
    });

    it('should return 400 if email is missing', async () => {
      const userData = {
        name: 'Test User'
      };

      const response = await request(app).post('/api/v1/users').send(userData).expect(400);

      expect(response.body).toHaveProperty('error', 'Name and email are required');
    });
  });

  describe('404 handler', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await request(app).get('/unknown-route').expect(404);

      expect(response.body).toHaveProperty('error', 'Route not found');
      expect(response.body).toHaveProperty('path', '/unknown-route');
    });
  });
});
