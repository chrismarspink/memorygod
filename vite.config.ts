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
			includeAssets: ['favicon.png', 'icons/*.png'],
			manifest: {
				id: '/memorygod/',
				name: '기억의 신',
				short_name: '기억의신',
				description: '과학적 망각곡선 기반 암기 앱',
				lang: 'ko',
				start_url: '/memorygod/',
				scope: '/memorygod/',
				display: 'standalone',
				orientation: 'portrait',
				background_color: '#ffffff',
				theme_color: '#1B3A6B',
				categories: ['education'],
				icons: [
					{
						src: '/memorygod/icons/icon-192.png',
						sizes: '192x192',
						type: 'image/png'
					},
					{
						src: '/memorygod/icons/icon-512.png',
						sizes: '512x512',
						type: 'image/png'
					},
					{
						src: '/memorygod/icons/icon-192-maskable.png',
						sizes: '192x192',
						type: 'image/png',
						purpose: 'maskable'
					},
					{
						src: '/memorygod/icons/icon-512-maskable.png',
						sizes: '512x512',
						type: 'image/png',
						purpose: 'maskable'
					}
				],
				screenshots: [
					{
						src: '/memorygod/icons/icon-512.png',
						sizes: '512x512',
						type: 'image/png',
						form_factor: 'narrow',
						label: '기억의 신 - 학습 화면'
					},
					{
						src: '/memorygod/icons/icon-512.png',
						sizes: '512x512',
						type: 'image/png',
						form_factor: 'wide',
						label: '기억의 신 - 데스크탑 화면'
					}
				]
			},
			workbox: {
				globPatterns: ['**/*.{js,css,html,ico,png,svg,webp,woff,woff2}'],
				navigateFallback: '/memorygod/index.html',
				navigateFallbackAllowlist: [/^\/memorygod\//],
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
