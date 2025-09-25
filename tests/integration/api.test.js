const request = require('supertest');
const app = require('../../src/app');

describe('Integration Tests', () => {
  describe('User workflow', () => {
    it('should handle complete user creation workflow', async () => {
      // First, check if API is healthy
      const healthResponse = await request(app).get('/health').expect(200);

      expect(healthResponse.body.status).toBe('OK');

      // Get initial users list
      const initialUsersResponse = await request(app).get('/api/v1/users').expect(200);

      expect(initialUsersResponse.body.data).toHaveLength(2);

      // Create a new user
      const newUser = {
        name: 'Integration Test User',
        email: 'integration@test.com'
      };

      const createUserResponse = await request(app).post('/api/v1/users').send(newUser).expect(201);

      expect(createUserResponse.body.data).toMatchObject({
        name: newUser.name,
        email: newUser.email
      });

      // Verify user creation response has required fields
      expect(createUserResponse.body.data).toHaveProperty('id');
      expect(createUserResponse.body.data).toHaveProperty('createdAt');
      expect(typeof createUserResponse.body.data.id).toBe('number');
      expect(typeof createUserResponse.body.data.createdAt).toBe('string');
    });

    it('should handle error cases gracefully', async () => {
      // Test missing required fields
      const invalidRequests = [
        { name: 'Only Name' },
        { email: 'only@email.com' },
        {},
        { name: '', email: '' }
      ];

      const responses = await Promise.all(
        invalidRequests.map(invalidData =>
          request(app).post('/api/v1/users').send(invalidData).expect(400)
        )
      );

      responses.forEach(response => {
        expect(response.body).toHaveProperty('error');
      });
    });
  });

  describe('API reliability', () => {
    it('should handle multiple concurrent requests', async () => {
      const numRequests = 10;
      const requests = Array.from({ length: numRequests }, (_, i) =>
        request(app)
          .post('/api/v1/users')
          .send({
            name: `User ${i}`,
            email: `user${i}@test.com`
          })
      );

      const responses = await Promise.all(requests);

      responses.forEach((response, index) => {
        expect(response.status).toBe(201);
        expect(response.body.data.name).toBe(`User ${index}`);
        expect(response.body.data.email).toBe(`user${index}@test.com`);
      });
    });

    it('should maintain health endpoint availability under load', async () => {
      const numRequests = 20;
      const healthRequests = Array.from({ length: numRequests }, () => request(app).get('/health'));

      const responses = await Promise.all(healthRequests);

      responses.forEach(response => {
        expect(response.status).toBe(200);
        expect(response.body.status).toBe('OK');
      });
    });
  });
});
