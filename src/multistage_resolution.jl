using DataDeps: run_checksum, run_fetch, run_post_fetch

struct MultistageResolution
    remote_path
    fetch_method
    hash
    path_fetch_method
end

function (msr::MultistageResolution)()
    fetched_paths = run_fetch(msr.fetch_method, msr.remote_path)
    run_checksum(fetched_paths, msr.hash)
    run_post_fetch(msr.path_fetch_method)
end

