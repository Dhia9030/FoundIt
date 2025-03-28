import * as admin from 'firebase-admin';
import * as path from 'path';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class FirebaseService {
  constructor(private configService: ConfigService) {
    // Utiliser un chemin absolu pour la clé
    const firebaseKeyPath = this.configService.get<string>('FIREBASE_ADMIN_SDK_KEY');
    
    if (!firebaseKeyPath) {
      throw new Error('La clé Firebase Admin SDK n\'est pas définie dans les variables d\'environnement.');
    }

    // Chemin absolu pour accéder au fichier JSON
    const absolutePath = path.resolve(__dirname, '..', firebaseKeyPath);

    console.log('Chemin absolu de la clé Firebase Admin SDK:', absolutePath);

    if (!admin.apps.length) {
      try {
        admin.initializeApp({
          credential: admin.credential.cert(absolutePath),
        });
      } catch (error) {
        console.error('Erreur d\'initialisation Firebase:', error);
      }
    }
  }

  async testFirebaseAuth(email: string, password: string) {
    try {
      const user = await admin.auth().getUserByEmail(email);
      return { message: 'Utilisateur trouvé', user };
    } catch (error) {
      return { message: 'Utilisateur non trouvé', error: (error as Error).message };
    }
  }
}
