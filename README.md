<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/dps_lab_title.png?sanitize=true" width=350/>
	</p>
  <h3>lab-platform-eks-ghactions</h3>
</div>
<br />

### Example of lab-plaform-eks pipeline using GitHub Actions

_See lab-platform-eks README for cluster configuration details_  

Dependencies and assumptions:  

* uses existing lab identities and credentials
* deploys _gha-sandbox_ cluster to _sandbox vpc_  
* deploys _gha-preview_ cluster to _preview vpc_
* clusters are ephemeral and not configured for ingress 

Manual configurations currently required by example:  

* SECRETHUB_CREDENTIAL added to repository secrets  
* _gha-sandbox_ and _gha-preview_ environments created
  * configured to require review
  * configured for _main_ branch only
