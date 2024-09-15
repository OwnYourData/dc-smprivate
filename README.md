# Private Data Store of Construction Site Manager
Implementation of a private data store based on Semantic Container for a construction site manger in the course of the NGI Sargasso DPP-CRC project.

## Resources
* Project description: https://www.ownyourdata.eu/en/dpp-crc/    
* Semantic Container: https://github.com/OwnYourData/semcon    
* Docker Hub: https://hub.docker.com/r/oydeu/sm-private

## Configuration Options

Use the following environment variables to configure the container:
* `ISSUER_DID` - DID of the trusted EPD issuance authority  
* `ISSUER_PWD` - private key for the DID of the trusted EPD issuance authority  
* `HOLDER_DID` - DID of the construction site manager  
* `HOLDER_PWD` - private key for the DID of the construction site manager    

&nbsp;    

## Issues

Please report bugs and suggestions for new features using the [GitHub Issue-Tracker](https://github.com/OwnYourData/dc-smprivate/issues) and follow the [Contributor Guidelines](https://github.com/twbs/ratchet/blob/master/CONTRIBUTING.md).

If you want to contribute, please follow these steps:

1. Fork it!
2. Create a feature branch: `git checkout -b my-new-feature`
3. Commit changes: `git commit -am 'Add some feature'`
4. Push into branch: `git push origin my-new-feature`
5. Send a Pull Request

&nbsp;    

## About  

<img align="right" src="https://raw.githubusercontent.com/OwnYourData/dc-cpprivate/main/app/assets/images/ngi-sargasso.png" height="50">This project has received funding from the European Union’s Horizon Europe research and innovation program through the [NGI SARGASSO program](https://ngisargasso.eu/) under cascade funding agreement No 101092887.

<br clear="both" />

## License

[MIT License 2024 - OwnYourData.eu](https://github.com/OwnYourData/dc-cpprivate/blob/main/LICENSE)