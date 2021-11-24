module main

import json
import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('vuild')
	fp.version('v0.0.1')
	fp.description('A build system for the V programming language')
	fp.skip_executable()

	file := fp.string('file', `f`, '', 'Specify the vuild file')
	b := fp.string('build', `b`, '', 'Specify which build is selected')

	fp.finalize() or {
		eprintln(err)
		eprintln(fp.usage())
		return
	}

	mut files := []string{}

	if file == '.' || file == '' {
		d := os.ls('.') or { panic(err) }
		files = d.filter(it.split('.').last() == 'vuild' && it.split('.').len > 1)	
	}


	if files.len == 0 {
		eprintln('Found no input files')
		return
	}

	for f in files {
		data := os.read_file('./$f') or { '' }
		v := json.decode(Vuild, data) or {
			eprintln(err)
			return
		}
		build(v, b) or {
			eprintln(err)
			return
		}
	}
}
