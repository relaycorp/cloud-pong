if [[ -f /tmp/failed-helmfile-hooks ]]; then
  echo "A helmfile hook has already failed" >&2
  exit 1
fi

trap '(( $? != 0 )) && echo "${BASH_SOURCE[0]}" >> /tmp/failed-helmfile-hooks' INT TERM EXIT
