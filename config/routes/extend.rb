scope '/' do
    # accept Verifiable Credentials
    match 'api/vc/accept/:id',    to: 'vcs#accept',    via: 'post'

    # aggregate Building Parts
    match 'api/bp/aggregate/:id', to: 'bps#aggregate', via: 'post'

    # generate  Building Part DPP
    match 'api/bp/generate/:id', to:  'bps#generate',  via: 'post'

end
