import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { FirebaseService } from './firebase.service'; // Import the FirebaseService
import { AuthController } from './auth.controller';

@Module({
  imports: [ConfigModule.forRoot()],
  controllers: [AppController, AuthController],
  providers: [AppService, FirebaseService], // Add FirebaseService to providers
  exports: [FirebaseService], // Export FirebaseService if needed in other modules
})
export class AppModule {}
