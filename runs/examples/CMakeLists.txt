CMAKE_MINIMUM_REQUIRED(VERSION 2.8.8 FATAL_ERROR)
include(ExternalData)

set(LOCAL_CACHE "")

function(probe_for_cache cache_dir)
    execute_process(COMMAND sh -c "install -m 777 -d ${cache_dir}/MD5"
        COMMAND sh -c "touch ${cache_dir}/MD5/.$ENV{USER}"
        COMMAND sh -c "rm ${cache_dir}/MD5/.$ENV{USER}"
        RESULT_VARIABLE is_writable ERROR_QUIET)

    if(${is_writable} EQUAL 0)
        message("Assets cache ${cache_dir} is writable.")
        set(LOCAL_CACHE ${LOCAL_CACHE} ${cache_dir} PARENT_SCOPE)
    else()
        message("Assets cache ${cache_dir} is not writable.")
    endif()
endfunction(probe_for_cache)

# We probe for the following cache directories in order of importance.
# Many different possible cluster locations writtable by users can be
# listed here. The benefit is to have cluster wide caches. Two fallback
# locations (/tmp/assets and $HOME/assets) are last resort where these
# "temporary" files can be stored for reuse by all users on the machine.
probe_for_cache("/work/imas/shared/boundary/solps-iter/assets")
probe_for_cache("/tmp/assets")
probe_for_cache("$ENV{HOME}/assets")

list(GET LOCAL_CACHE 0 first_cache)
message("Using assets cache ${first_cache}")

# Cashed assets (download dir) can be firtsly looked cluster wide then home
# However, if(EXISTS <directory>) with write permissions needs to be tested
# before such system-wide asset handling can be implemented.
set(ExternalData_OBJECT_STORES
    ${LOCAL_CACHE}
)

# Where too look externally if hashed files can't be found in the cache
set(ExternalData_URL_TEMPLATES
    "http://static.iter.org/imas/assets/solps-iter/%(algo)/%(hash)"
    "http://viz.hpc.fs.uni-lj.si/assets/solps-iter/%(algo)/%(hash)"
    "file://$ENV{HOME}/assets/%(algo)/%(hash)"
    # The last asset template in user's home directory is only meaningful
    # when the user extracted assests he got as a bunch for local use or
    # for the case when he/she is preparing the case for upload to real
    # web servers above.
)

# Location of *.md5 files to be scanned and replaced from external sources
ExternalData_Expand_Arguments(solps_externalData examples
     DATA{./,REGEX:.*\\.tar\\.gz}
)

ExternalData_Add_Target(solps_externalData)
