#!/bin/sh
if [ -n "$*" ]; then
	docker-compose run qmk_compiler nose2 test_qmk_compiler.test_0000_checkout_qmk_skip_cache $@ test_qmk_compiler.test_9999_teardown
else
	docker-compose run qmk_compiler nose2
fi
