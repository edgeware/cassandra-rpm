#!/bin/sh

get_full_path() {
        local p="$1"
        ( cd "${p}" ; pwd )
}

install_files() {
	SOURCE_DIR="$(get_full_path $(dirname "$0"))"
	
	# Install bin and lib
	install_recursive "../apache-cassandra-${version}/bin" "/usr/share/cassandra/bin"
	install_recursive "../apache-cassandra-${version}/lib" "/usr/share/cassandra/lib"

    # Create lib dirs
    create_dirs "/var/run/cassandra" \
        "/var/log/cassandra" \
        "/var/lib/cassandra/commitlog" \
        "/var/lib/cassandra/data" \
        "/var/lib/cassandra/saved_caches"
	 
	# Documents
	install_recursive "../apache-cassandra-${version}/javadoc" "/usr/share/doc/cassandra/javadoc"
	install_file "../apache-cassandra-${version}" "/usr/share/doc/cassandra" "CHANGES.txt"
	install_file "../apache-cassandra-${version}" "/usr/share/doc/cassandra" "LICENSE.txt"
	install_file "../apache-cassandra-${version}" "/usr/share/doc/cassandra" "NEWS.txt"
	install_file "../apache-cassandra-${version}" "/usr/share/doc/cassandra" "NOTICE.txt"
	install_file "../apache-cassandra-${version}" "/usr/share/doc/cassandra" "README.txt"
	
	# Configuration
	install_recursive "../apache-cassandra-${version}/conf" "/etc/cassandra/default.conf"
	install_recursive "./etc" "/etc"
	install_recursive "./usr" "/usr"
}

install_recursive() {
        local src="$1"
        local dst="$2"
        local d

        install -m 0755 -d "${DESTDIR}${dst}"
        ( cd "${SOURCE_DIR}/${src}" && find . -type d ) | while read d; do
                if [ "${d}" != "." ]; then
                [ -d "${DESTDIR}${dst}/${d}" ] || install -m 0755 -d "${DESTDIR}${dst}/${d}" || die "Cannot create ${d}"
                fi
        done || die "Cannot copy recursive ${src}"

        ( cd "${SOURCE_DIR}/${src}" && find . -type f ) | while read f; do
            install_file "${src}" "${dst}" "${f}" 
   	 	done || die "Cannot copy recursive ${src}"

        return 0
}

install_file() {
        local src="$1"
        local dst="$2"
		local f="$3"
		
		local mask
        [ "${f%%.sh}" == "${f}" ] && mask="0644" || mask="0755"
        install -m "${mask}" "${SOURCE_DIR}/${src}/${f}" "${DESTDIR}${dst}/${f}" || die "Cannot install ${f}"
}

create_dirs() {
        while [ -n "$1" ]; do
                local d="$1"; shift
                install -m 0755 -d "${DESTDIR}${d}" || die "Failed on creating ${d} directory"
        done
}

copy_initscripts() {
        for d in \
                "${DESTDIR}/etc/sysconfig" \
                "${DESTDIR}/etc/init.d" \
                "${DESTDIR}/etc/logrotate.d" \
                "${DESTDIR}/etc/cron.d" \
                ; do
                install -m 0755 -d "${d}" || die "Failed on creating ${d}"
        done

        while [ -n "$1" ]; do
                local service="$1"; shift
                install -m 0755 "${SOURCE_DIR}/misc/${service}.init.d.redhat" "${DESTDIR}/etc/init.d/${service}" || die "Failed on installing ${service}.init.d.redhat"
                install -m 0644 "${SOURCE_DIR}/misc/${service}.conf.d" "${DESTDIR}/etc/sysconfig/${service}" || die "Failed on installing ${service}.conf.d"

                if [ -f "${SOURCE_DIR}/misc/logrotate.d/${service}.logrotate.redhat" ]; then
                        install -m 0644 "${SOURCE_DIR}/misc/logrotate.d/${service}.logrotate.redhat" "${DESTDIR}/etc/logrotate.d/${service}" || die "Failed on installing ${service}.logrotate.redhat"
                fi

                if [ -f "${SOURCE_DIR}/misc/cron.d/${service}.cron" ]; then
                        install -m 0644 "${SOURCE_DIR}/misc/cron.d/${service}.cron" "${DESTDIR}/etc/cron.d/${service}" || die "Failed on installing ${service}.cron"
                fi
        done
}


main() {
	install_files
	[ -n "${INIT_SCRIPTS}" ] && copy_initscripts "cassandra"
}


while [ -n "$1" ]; do
	v="${1#*=}"
	case "$1" in
		--init-scripts)
			INIT_SCRIPTS=1
			;;
		--help|*)
			cat <<__EOF__
Usage: $0
        --init-scripts     - Copy init scripts
__EOF__
			exit 1
	esac
	shift
done

main
exit 0