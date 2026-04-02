import { writable } from 'svelte/store';
import type { User } from '@supabase/supabase-js';
import { supabase } from './supabase';

export const user = writable<User | null>(null);

export async function initAuth() {
	const { data } = await supabase.auth.getSession();
	user.set(data.session?.user ?? null);

	supabase.auth.onAuthStateChange((_event, session) => {
		user.set(session?.user ?? null);
	});
}

export async function signUp(email: string, password: string) {
	const { data, error } = await supabase.auth.signUp({ email, password });
	if (error) throw error;
	return data;
}

export async function signIn(email: string, password: string) {
	const { data, error } = await supabase.auth.signInWithPassword({ email, password });
	if (error) throw error;
	return data;
}

export async function signOut() {
	const { error } = await supabase.auth.signOut();
	if (error) throw error;
}
