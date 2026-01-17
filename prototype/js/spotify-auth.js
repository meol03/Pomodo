/**
 * Spotify Authentication with PKCE (Proof Key for Code Exchange)
 * No backend required!
 */

const SpotifyAuth = {
  // Configuration - UPDATE THESE VALUES!
  CLIENT_ID: 'YOUR_CLIENT_ID', // Get from https://developer.spotify.com/dashboard
  REDIRECT_URI: 'http://localhost:8000/callback.html', // Or your production URL
  SCOPES: 'user-read-playback-state user-modify-playback-state',

  /**
   * Base64 URL encode (RFC 4648 base64url encoding)
   */
  base64URLEncode(buffer) {
    return btoa(String.fromCharCode(...new Uint8Array(buffer)))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  },

  /**
   * Generate cryptographically random code verifier
   */
  generateCodeVerifier() {
    const array = new Uint8Array(64);
    crypto.getRandomValues(array);
    return this.base64URLEncode(array);
  },

  /**
   * Generate code challenge from verifier
   */
  async generateCodeChallenge(verifier) {
    const data = new TextEncoder().encode(verifier);
    const hash = await crypto.subtle.digest('SHA-256', data);
    return this.base64URLEncode(hash);
  },

  /**
   * Generate random state for CSRF protection
   */
  generateRandomString(length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  },

  /**
   * Redirect user to Spotify authorization page
   */
  async login() {
    // Generate and store code verifier
    const codeVerifier = this.generateCodeVerifier();
    localStorage.setItem('code_verifier', codeVerifier);

    // Generate code challenge
    const codeChallenge = await this.generateCodeChallenge(codeVerifier);

    // Generate state for CSRF protection
    const state = this.generateRandomString(16);
    localStorage.setItem('auth_state', state);

    // Build authorization URL
    const params = new URLSearchParams({
      client_id: this.CLIENT_ID,
      response_type: 'code',
      redirect_uri: this.REDIRECT_URI,
      scope: this.SCOPES,
      code_challenge_method: 'S256',
      code_challenge: codeChallenge,
      state: state
    });

    // Redirect to Spotify authorization
    window.location.href = `https://accounts.spotify.com/authorize?${params.toString()}`;
  },

  /**
   * Exchange authorization code for access token
   */
  async exchangeCodeForToken(code, codeVerifier) {
    try {
      const response = await fetch('https://accounts.spotify.com/api/token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
          client_id: this.CLIENT_ID,
          grant_type: 'authorization_code',
          code: code,
          redirect_uri: this.REDIRECT_URI,
          code_verifier: codeVerifier
        })
      });

      const data = await response.json();

      if (data.access_token) {
        // Store tokens
        localStorage.setItem('access_token', data.access_token);
        localStorage.setItem('refresh_token', data.refresh_token);
        localStorage.setItem('expires_at', Date.now() + (data.expires_in * 1000));

        console.log('✓ Successfully obtained access token');
        return true;
      } else {
        console.error('Failed to get access token:', data);
        return false;
      }
    } catch (error) {
      console.error('Token exchange error:', error);
      return false;
    }
  },

  /**
   * Refresh access token using refresh token
   */
  async refreshAccessToken() {
    const refreshToken = localStorage.getItem('refresh_token');

    if (!refreshToken) {
      console.error('No refresh token available');
      return null;
    }

    try {
      const response = await fetch('https://accounts.spotify.com/api/token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
          client_id: this.CLIENT_ID,
          grant_type: 'refresh_token',
          refresh_token: refreshToken
        })
      });

      const data = await response.json();

      if (data.access_token) {
        localStorage.setItem('access_token', data.access_token);
        localStorage.setItem('expires_at', Date.now() + (data.expires_in * 1000));

        // Refresh token may be rotated
        if (data.refresh_token) {
          localStorage.setItem('refresh_token', data.refresh_token);
        }

        console.log('✓ Access token refreshed');
        return data.access_token;
      } else {
        console.error('Failed to refresh token:', data);
        return null;
      }
    } catch (error) {
      console.error('Token refresh error:', error);
      return null;
    }
  },

  /**
   * Get valid access token (refreshes if needed)
   */
  async getAccessToken() {
    const token = localStorage.getItem('access_token');
    const expiresAt = localStorage.getItem('expires_at');

    if (!token || !expiresAt) {
      return null;
    }

    // Check if token is expired or about to expire (5 min buffer)
    if (Date.now() >= (parseInt(expiresAt) - 5 * 60 * 1000)) {
      console.log('Token expired, refreshing...');
      return await this.refreshAccessToken();
    }

    return token;
  },

  /**
   * Check if user is logged in
   */
  isLoggedIn() {
    return localStorage.getItem('access_token') !== null;
  },

  /**
   * Logout (clear stored tokens)
   */
  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('expires_at');
    console.log('✓ Logged out');
  }
};
