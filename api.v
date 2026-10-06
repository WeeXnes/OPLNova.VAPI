module main

import veb
import os

struct App {
	veb.StaticHandler
mut:
	game_map map[string]string
}

struct Context {
	veb.Context
}

fn main() {
	mut game_map := map[string]string{}
	db_path := 'db/PS2_LIST.txt'
	if os.exists(db_path) {
		content := os.read_file(db_path) or { '' }
		lines := content.split('\n')
		for line in lines {
			trimmed := line.trim_space()
			if trimmed == '' {
				continue
			}

			parts := trimmed.split_nth(' ', 2)
			if parts.len == 2 {
				id := parts[0].trim_space()
				title := parts[1].trim_space()
				game_map[id] = title
			}
		}
	} else {
		println('Warning: ${db_path} not found.')
	}

	cert_dir := os.join_path(os.home_dir(), 'certs')
	key_path := os.join_path(cert_dir, 'privkey.pem')
	cert_path := os.join_path(cert_dir, 'cert.pem')
	ca_path := os.join_path(cert_dir, 'fullchain.pem')

	are_certs_present := os.exists(key_path) && os.exists(cert_path) && os.exists(ca_path)

	port := 3000
	if are_certs_present {
		println('SSL certificates found. Starting HTTPS server...')
		println('Note: HTTPS not strictly enforced in this V port (running HTTP on port ${port}).')
	} else {
		println('SSL certificates not found. Starting HTTP server...')
		println('HTTP Server running at http://localhost:${port}')
	}

	mut app := &App{
		game_map: game_map
	}

	veb.run[App, Context](mut app, port)
}

fn normalize_id(input string) string {
	cleaned := input.to_upper().replace('_', '').replace('.', '')

	mut digit_idx := -1
	for i, ch in cleaned {
		if ch.is_digit() {
			digit_idx = i
			break
		}
	}

	if digit_idx > 0 {
		prefix := cleaned[..digit_idx]
		digits := cleaned[digit_idx..]

		mut is_prefix_alpha := true
		for i := 0; i < prefix.len; i++ {
			if !prefix[i].is_letter() {
				is_prefix_alpha = false
				break
			}
		}

		mut is_digits_numeric := true
		for i := 0; i < digits.len; i++ {
			if !digits[i].is_digit() {
				is_digits_numeric = false
				break
			}
		}

		if is_prefix_alpha && is_digits_numeric {
			return '${prefix}-${digits}'
		}
	}

	return cleaned
}

pub fn (mut app App) index(mut ctx Context) veb.Result {
	if os.exists('index.html') {
		return ctx.file('index.html')
	}
	return ctx.text('index.html not found')
}

@['/contact']
pub fn (mut app App) contact(mut ctx Context) veb.Result {
	if os.exists('contact.html') {
		return ctx.file('contact.html')
	}
	return ctx.text('contact.html not found')
}

@['/search/:id']
pub fn (mut app App) search(mut ctx Context, id string) veb.Result {
	normalized := normalize_id(id)
	title := app.game_map[normalized] or { '' }

	if title != '' {
		return ctx.json({
			'id':    normalized
			'title': title
		})
	}

	ctx.res.set_status(.not_found)
	return ctx.json({
		'error': 'Game ID not found'
	})
}

@['/art/:file']
pub fn (mut app App) art(mut ctx Context, file string) veb.Result {
	if file.contains('..') {
		return ctx.not_found()
	}

	// 1. Direct match: db/PS2/{file}
	path := os.join_path('db/PS2', file)
	if os.exists(path) {
		return ctx.file(path)
	}

	// 2. Try alternate extensions (jpg <-> png)
	base := file.all_before_last('.')
	ext := file.all_after_last('.')
	alt_ext := if ext.to_lower() == 'png' { 'jpg' } else { 'png' }
	alt_path := os.join_path('db/PS2', '${base}.${alt_ext}')
	if os.exists(alt_path) {
		return ctx.file(alt_path)
	}

	// 3. Try converting between normalized (SLUS-20002) and legacy (SLUS_200.02)
	if base.contains('_') {
		id_part := base.all_before_last('_')
		suffix_part := base.all_after_last('_')

		if id_part.contains('-') {
			parts := id_part.split('-')
			if parts.len == 2 && parts[1].len == 5 {
				legacy_id := '${parts[0]}_${parts[1][..3]}.${parts[1][3..]}'
				for e in ['png', 'jpg'] {
					candidate := os.join_path('db/PS2', '${legacy_id}_${suffix_part}.${e}')
					if os.exists(candidate) {
						return ctx.file(candidate)
					}
				}
			}
		} else {
			norm_id := normalize_id(id_part)
			for e in ['png', 'jpg'] {
				candidate := os.join_path('db/PS2', '${norm_id}_${suffix_part}.${e}')
				if os.exists(candidate) {
					return ctx.file(candidate)
				}
			}
		}
	}

	return ctx.not_found()
}
