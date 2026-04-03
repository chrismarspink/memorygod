import { env } from '$env/dynamic/public';

declare global {
	interface Window {
		OneSignalDeferred?: Array<(OneSignal: any) => Promise<void>>;
	}
}

const ONESIGNAL_APP_ID = env.PUBLIC_ONESIGNAL_APP_ID;

export function initOneSignal() {
	if (!ONESIGNAL_APP_ID || ONESIGNAL_APP_ID === 'placeholder') return;

	window.OneSignalDeferred = window.OneSignalDeferred || [];
	window.OneSignalDeferred.push(async (OneSignal: any) => {
		await OneSignal.init({
			appId: ONESIGNAL_APP_ID,
			notifyButton: { enable: false },
			allowLocalhostAsSecureOrigin: true
		});
	});
}

export async function subscribeUser(userId: string) {
	if (!ONESIGNAL_APP_ID || ONESIGNAL_APP_ID === 'placeholder') return;

	window.OneSignalDeferred = window.OneSignalDeferred || [];
	window.OneSignalDeferred.push(async (OneSignal: any) => {
		await OneSignal.Notifications.requestPermission();
		await OneSignal.login(userId);
	});
}

export async function unsubscribeUser() {
	window.OneSignalDeferred = window.OneSignalDeferred || [];
	window.OneSignalDeferred.push(async (OneSignal: any) => {
		await OneSignal.logout();
	});
}
