BEGIN {
	use Cwd;
	use File::Spec;
	use File::Basename;

	eval {
		require MT;
	};
	if ($@) {
		my $dir = File::Spec->rel2abs(getcwd);
		while ($dir ne '/') {
			my $mt = File::Spec->catfile($dir, 'lib', 'MT.pm');
			if (-e $mt) {
				push @INC,
				File::Spec->catdir($dir, 'lib'),
				File::Spec->catdir($dir, 'extlib');

    			$ENV{MT_HOME} = $dir;
				$ENV{MT_CONFIG} = File::Spec->catfile($dir, 'mt-config.cgi');

				last;
			}
			$dir = dirname($dir);
		}
	}
}

{
	require MT::Bootstrap;
	require MT;

	my $mt = MT->new() or die MT->errstr;

	$mt->{vtbl} = { };
	$mt->{is_admin} = 0;
	$mt->{template_dir} = 'cms';
	$mt->{user_class} = 'MT::Author';
	$mt->{plugin_template_path} = 'tmpl';
	$mt->run_callbacks('init_app', $mt);
}

1;
