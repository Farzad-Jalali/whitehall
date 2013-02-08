Feature: Administering Roles
  tHis feature allows the administration of the various different roles in the system

Background:
  Given I am an admin

Scenario: Adding a traffic commissioner role
  Given the organisation "Department for Transport" exists
  And a person called "Terence Traffic"
  When I add a new "Traffic commissioner" role named "Traffic Commissioner for Scotland" to the "Department for Transport"
  Then I should be able to appoint "Terence Traffic" to the new role
  And I should see "Terence Traffic" listed on the "Department for Transport" organisation page

Scenario: Adding a chief scientist
  Given the organisation "Foreign Office" exists
  And a person called "Susan Scientist"
  When I add a new "Chief scientific advisor" role named "Chief Scientific Advisor to the FCO" to the "Foreign Office"
  Then I should be able to appoint "Susan Scientist" to the new role
  And I should see "Susan Scientist" listed on the "Foreign Office" organisation page

Scenario: Adding an ambassador role to a worldwide office
  Given the worldwide office "British embassy in Spain" exists
  And a person called "Giles Paxman"
  When I add a new "Ambassador" role named "Her Majesty's Ambassador to Spain" to the "British embassy in Spain" office
  Then I should be able to appoint "Giles Paxman" to the new role
  And I should see "Giles Paxman" listed as "Her Majesty's Ambassador to Spain" on the "British embassy in Spain" office page
