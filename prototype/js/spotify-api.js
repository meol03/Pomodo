/**
 * Spotify API - Playback Control
 * Handles play, pause, volume control, and fade transitions
 */

const SpotifyAPI = {
  BASE_URL: 'https://api.spotify.com/v1',

  /**
   * Make authenticated request to Spotify API
   */
  async makeRequest(endpoint, options = {}) {
    const token = await SpotifyAuth.getAccessToken();

    if (!token) {
      console.error('No valid access token');
      return null;
    }

    try {
      const response = await fetch(`${this.BASE_URL}${endpoint}`, {
        ...options,
        headers: {
          'Authorization': `Bearer ${token}`,
          ...options.headers
        }
      });

      // Handle 204 No Content (successful but no data)
      if (response.status === 204) {
        return { success: true };
      }

      // Handle 401 Unauthorized (token expired)
      if (response.status === 401) {
        console.log('Token invalid, refreshing...');
        const newToken = await SpotifyAuth.refreshAccessToken();

        if (newToken) {
          // Retry request with new token
          return this.makeRequest(endpoint, options);
        }
        return null;
      }

      // Handle 404 (no active device)
      if (response.status === 404) {
        return { error: 'No active device found', status: 404 };
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('API request error:', error);
      return null;
    }
  },

  /**
   * Get current playback state
   */
  async getPlaybackState() {
    const data = await this.makeRequest('/me/player');

    if (!data || data.error) {
      return null;
    }

    return {
      isPlaying: data.is_playing,
      volumePercent: data.device?.volume_percent,
      deviceName: data.device?.name,
      deviceId: data.device?.id,
      trackName: data.item?.name,
      artistName: data.item?.artists?.[0]?.name,
      albumArt: data.item?.album?.images?.[0]?.url
    };
  },

  /**
   * Pause playback
   */
  async pause() {
    const result = await this.makeRequest('/me/player/pause', {
      method: 'PUT'
    });

    if (result?.error) {
      console.error('Pause failed:', result.error);
      return false;
    }

    console.log('✓ Playback paused');
    return true;
  },

  /**
   * Resume playback
   */
  async play() {
    const result = await this.makeRequest('/me/player/play', {
      method: 'PUT'
    });

    if (result?.error) {
      console.error('Play failed:', result.error);
      return false;
    }

    console.log('✓ Playback resumed');
    return true;
  },

  /**
   * Set volume (0-100)
   */
  async setVolume(volumePercent) {
    const volume = Math.max(0, Math.min(100, volumePercent));

    const result = await this.makeRequest(`/me/player/volume?volume_percent=${volume}`, {
      method: 'PUT'
    });

    if (result?.error) {
      console.error('Set volume failed:', result.error);
      return false;
    }

    return true;
  },

  /**
   * Sleep helper for fade transitions
   */
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  },

  /**
   * Fade out and pause
   */
  async fadeOutAndPause(durationMs = 3000) {
    console.log(`Fading out over ${durationMs}ms...`);

    // Get current state
    const state = await this.getPlaybackState();

    if (!state) {
      console.log('No playback state available');
      return false;
    }

    if (!state.isPlaying) {
      console.log('Music already paused');
      return true;
    }

    const originalVolume = state.volumePercent || 50;

    // If instant fade, just pause
    if (durationMs === 0) {
      return await this.pause();
    }

    // Gradual fade
    const steps = 20;
    const stepDuration = durationMs / steps;
    const volumeDecrement = originalVolume / steps;

    try {
      // Decrease volume gradually
      for (let i = steps; i > 0; i--) {
        const newVolume = Math.round(volumeDecrement * i);
        await this.setVolume(newVolume);
        await this.sleep(stepDuration);
      }

      // Pause at volume 0
      await this.pause();

      // Restore original volume (so it's ready for next play)
      await this.setVolume(originalVolume);

      console.log('✓ Fade out complete');
      return true;
    } catch (error) {
      console.error('Fade out error:', error);
      // Try to pause anyway
      await this.pause();
      return false;
    }
  },

  /**
   * Resume and fade in
   */
  async resumeAndFadeIn(targetVolume = 50, durationMs = 3000) {
    console.log(`Fading in over ${durationMs}ms...`);

    // If instant fade, just play
    if (durationMs === 0) {
      return await this.play();
    }

    try {
      // Set volume to 0 before resuming
      await this.setVolume(0);

      // Resume playback
      await this.play();

      // Wait a moment for playback to start
      await this.sleep(100);

      // Gradual fade in
      const steps = 20;
      const stepDuration = durationMs / steps;
      const volumeIncrement = targetVolume / steps;

      for (let i = 1; i <= steps; i++) {
        const newVolume = Math.round(volumeIncrement * i);
        await this.setVolume(newVolume);
        await this.sleep(stepDuration);
      }

      console.log('✓ Fade in complete');
      return true;
    } catch (error) {
      console.error('Fade in error:', error);
      // Try to play anyway
      await this.play();
      return false;
    }
  }
};
