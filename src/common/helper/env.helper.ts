import { resolve } from 'path';

export function getEnvPath(dest: string): string {
  const env: string | undefined = process.env.NODE_ENV;
  const filename: string = env ? `.${env}.env` : '.development.env';
  return resolve(`${dest}/${filename}`);
}

/**
 * Processes environment variables to handle multiline strings
 * Converts \n escape sequences to actual newlines for JWT keys
 */
export function processEnvVars(
  config: Record<string, unknown>,
): Record<string, unknown> {
  const processed = { ...config };

  // List of environment variables that should have their \n converted to newlines
  const multilineVars = [
    'JWT_PRIVATE_KEY',
    'JWT_PUBLIC_KEY',
    'JWT_REFRESH_TOKEN_PRIVATE_KEY',
    'jwt_private_key',
    'jwt_public_key',
    'jwt_refresh_token_private_key',
  ];

  multilineVars.forEach((varName) => {
    if (processed[varName] && typeof processed[varName] === 'string') {
      processed[varName] = (processed[varName] as string).replace(/\\n/g, '\n');
    }
  });

  // Also normalize case for JWT keys to uppercase
  if (processed.jwt_private_key) {
    processed.JWT_PRIVATE_KEY = processed.jwt_private_key;
    delete processed.jwt_private_key;
  }
  if (processed.jwt_public_key) {
    processed.JWT_PUBLIC_KEY = processed.jwt_public_key;
    delete processed.jwt_public_key;
  }
  if (processed.jwt_refresh_token_private_key) {
    processed.JWT_REFRESH_TOKEN_PRIVATE_KEY =
      processed.jwt_refresh_token_private_key;
    delete processed.jwt_refresh_token_private_key;
  }

  return processed;
}
