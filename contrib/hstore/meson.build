# .. so that includes of hstore/hstore.h work
hstore_inc = include_directories('.', '../')

hstore = shared_module('hstore',
  files(
    'hstore_compat.c',
    'hstore_gin.c',
    'hstore_gist.c',
    'hstore_io.c',
    'hstore_op.c',
    'hstore_subs.c',
  ),
  kwargs: contrib_mod_args,
)
contrib_targets += hstore

install_data(
  'hstore.control',
  'hstore--1.1--1.2.sql',
  'hstore--1.2--1.3.sql',
  'hstore--1.3--1.4.sql',
  'hstore--1.4.sql',
  'hstore--1.4--1.5.sql',
  'hstore--1.5--1.6.sql',
  'hstore--1.6--1.7.sql',
  'hstore--1.7--1.8.sql',
  kwargs: contrib_data_args,
)

install_headers(
  'hstore.h',
  install_dir: dir_include_extension / 'hstore',
)

tests += {
  'name': 'hstore',
  'sd': meson.current_source_dir(),
  'bd': meson.current_build_dir(),
  'regress': {
    'sql': [
      'hstore',
    ],
  },
}