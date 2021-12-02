module main

struct Vuild {
	v             Version
	default_build string           [json: 'defaultBuild']
	builds        map[string]Build
	dependencies  []Dependency
}

struct Version {
	upstream    string
	min_version string [json: 'minVersion']
	cflags      string
}

struct Build {
	target string
	output string
	args   []string
}

struct Dependency {
	name string
	lib  map[string][]string
}
