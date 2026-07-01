import swaggerJsdoc from 'swagger-jsdoc';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Landmark Navigation API',
      version: '1.0.0',
    },
  },
  apis: ['./docs/*.yaml'],
};

export const swaggerSpec = swaggerJsdoc(options);
