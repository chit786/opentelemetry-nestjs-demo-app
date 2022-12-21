import { INestApplication, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

// import { LoggingInterceptor } from 'libs/LoggingInterceptor';
import { Logger } from 'nestjs-pino';
import { HttpExceptionFilter } from 'libs/HttpExceptionFilter';

import { Config } from 'src/Config';
import { AppModule } from 'src/AppModule';
import helmet from 'helmet';
import compression from 'compression';
import otelSDK from 'src/opentelemetry';

function setupSwagger(app: INestApplication): void {
  const documentBuilder = new DocumentBuilder()
    .setTitle('Nest.js example')
    .setDescription('This is example for nest.js')
    .setVersion('1.0')
    .addBasicAuth()
    .build();

  const document = SwaggerModule.createDocument(app, documentBuilder);
  SwaggerModule.setup('api', app, document, {
    swaggerOptions: { defaultModelsExpandDepth: -1 },
  });
}

async function bootstrap() {
  await otelSDK
    .start()
    .then(() => {
      console.log('Tracing initialized');
    })
    .catch((error) => console.log('Error initializing tracing', error));

  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  app.enableCors();
  app.use(helmet());
  app.use(compression());
  app.useGlobalPipes(new ValidationPipe());
  app.useLogger(app.get(Logger));
  // app.useGlobalInterceptors(new LoggingInterceptor());
  app.useGlobalFilters(new HttpExceptionFilter());
  setupSwagger(app);
  await app.listen(Config.PORT);
}

bootstrap();
