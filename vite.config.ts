import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';
import { SvelteKitPWA } from '@vite-pwa/sveltekit';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [
		tailwindcss(),
		sveltekit(),
		SvelteKitPWA({
			registerType: 'autoUpdate',
			manifest: {
				name: '기억의 신',
				short_name: '기억의신',
				description: '과학적 망각곡선 암기 앱',
				start_url: '/memorygod/',
				scope: '/memorygod/',
				display: 'standalone',
				background_color: '#ffffff',
				theme_color: '#1B3A6B',
				icons: [
					{ src: '/memorygod/icons/icon-192.png', sizes: '192x192', type: 'image/png' },
					{ src: '/memorygod/icons/icon-512.png', sizes: '512x512', type: 'image/png' }
				]
			},
			workbox: {
				globPatterns: ['**/*.{js,css,html,ico,png,svg,webp,woff,woff2}'],
				runtimeCaching: [
					{
						urlPattern: /^https:\/\/pmnzhemxdfsgktqgtbca\.supabase\.co/,
						handler: 'NetworkFirst',
						options: {
							cacheName: 'supabase-api',
							expiration: { maxEntries: 50, maxAgeSeconds: 300 }
						}
					}
				]
			}
		})
	]
});
