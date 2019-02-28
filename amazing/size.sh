#!/bin/bash -ex
find lib -name "*.dart" | xargs cat | wc -c
