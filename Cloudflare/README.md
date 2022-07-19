**zone-shredder**

CF has a nasty habbit of caching zone records so when recreating a zone the records will still be there I needed to recreate some zones so they could be controlled through terraform with the naming structure I wanted for the resources so this script enssestially so through the records one by one deletes them and then the zone.

Would be good for some testing environments too when writing new terraform (or simular) modules
