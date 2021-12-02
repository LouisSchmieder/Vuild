module main

import os

struct VersionS {
	major int
	minor int
	patch int
}

fn (a VersionS) < (b VersionS) bool {
	major := a.major < b.major
	emajor := a.major == b.major
	minor := a.minor < b.minor
	eminor := a.minor == b.minor
	patch := a.patch < b.patch
	return major || (emajor && minor) || (emajor && eminor && patch)
}

fn (a VersionS) == (b VersionS) bool {
	return a.major == b.major && a.minor == b.minor && a.patch == b.patch
}

fn (v VersionS) str() string {
	return '${v.major}.${v.minor}.$v.patch'
}

fn create_version(major int, minor int, patch int) VersionS {
	return VersionS{
		major: major
		minor: minor
		patch: patch
	}
}

fn version_from_string(s string) VersionS {
	parts := s.split('.')
	if parts.len == 0 {
		return create_version(0, 0, 0)
	} else if parts.len == 1 {
		return create_version(parts[0].int(), 0, 0)
	} else if parts.len == 2 {
		return create_version(parts[0].int(), parts[1].int(), 0)
	} else {
		return create_version(parts[0].int(), parts[1].int(), parts[2].int())
	}
}

fn build(b Vuild, bb string) ? {
	eprintln('Checking V version: ...')
	check_v_version(b.v) ?
	eprintln('Checking V version: done')
	eprintln('Installing dependencies: ...')
	install_dependencies(b.dependencies) ?
	eprintln('Installing dependencies: done')

	if b.default_build == '' {
		return error('A default build has to be set')
	}
	if b.default_build !in b.builds {
		return error('The default build name has to be valid')
	}

	mut build_name := bb
	if bb == '' {
		build_name = b.default_build
	} else {
		if bb !in b.builds {
			return error('Unknown build `$bb`')
		}
	}

	eprintln('Using build: $build_name')
	build := b.builds[build_name]

	eprintln('Building application: ...')
	build_application(build, b.v.cflags) ?
	eprintln('Building application: done')
}

fn build_application(b Build, cflags string) ? {
	mut target := b.target
	if b.target == '' {
		eprintln('No target file given. Using default `.`')
		target = '.'
	}
	mut output := '-o $b.output'
	if b.output == '' {
		eprintln('No output file given. Using default output')
		output = ''
	}

	cmd := 'v $cflags $target $output ${b.args.join(' ')}'
	exec(cmd) ?
}

fn check_v_version(v Version) ? {
	output := exec('v --version') ?
	version := output[2..].fields()[0]
	min_version := version_from_string(v.min_version)
	ac_version := version_from_string(version)

	if ac_version < min_version {
		return error('The V version which is installed, is to low: Required `$min_version`, Installed: `$ac_version`')
	}
}

fn install_dependencies(deps []Dependency) ? {
	mut ops := ''
	$if linux {
		ops = 'linux'
	} $else $if windows {
		ops = 'windows'
	} $else $if macos {
		ops = 'macos'
	}

	eprintln('Got os: $ops')
	for dep in deps {
		if ops in dep.lib {
			cmds := dep.lib[ops]

			mut finshed := 0

			for cmd in cmds {
				res := os.execute(cmd)
				if res.exit_code == 0 {
					finshed++
				}
			}
			eprintln('Executed $finshed/$cmds.len')
		}
	}
}

pub fn exec(msg string) ?string {
	res := os.execute(msg)
	if res.exit_code == 0 {
		return res.output
	}
	return error(res.output)
}
