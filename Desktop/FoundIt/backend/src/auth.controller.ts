import { Controller, Post, Body } from '@nestjs/common';
import { FirebaseService } from './firebase.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly firebaseService: FirebaseService) {}

  @Post('test')
  async testFirebase(@Body() body: { email: string; password: string }) {
    const { email, password } = body;
    return this.firebaseService.testFirebaseAuth(email, password);
  }
}
