*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Variables ***
${BANNER_STATUS}    id:banner-status
${NEXT_BTN}         xpath://button[contains(@aria-label,'ext') or normalize-space()='›']
${PREV_BTN}         xpath://button[contains(@aria-label,'rev') or normalize-space()='‹']
${HIDDEN_SLIDES}    xpath://*[@aria-hidden='true']

*** Test Cases ***
Le Carrousel Demarre Sur La Slide 1
    [Tags]    smoke
    Element Text Should Be    ${BANNER_STATUS}    1 of 4

 Bouton Suivant
     Click Element    ${NEXT_BTN}
     Element Text Should Be    ${BANNER_STATUS}    2 of 4

 Bouton Precedent Revient A La Derniere Slide
     Click Element    ${PREV_BTN}
     Element Text Should Be    ${BANNER_STATUS}    4 of 4

 Defilement Automatique
     Element Text Should Be    ${BANNER_STATUS}    1 of 4
     Sleep    6s
     Element Text Should Not Be    ${BANNER_STATUS}    1 of 4

 Les Slides Masquees Sont Aria Hidden
     ${count}=    Get Element Count    ${HIDDEN_SLIDES}
     Should Be True    ${count} >= 3

# Application: boucle WHILE pour faire le tour du carrousel
 Faire Le Tour Du Carrousel Avec Boucle
     ${tours}=    Set Variable    0
     WHILE    ${tours} < 4    limit=6
         Click Element    ${NEXT_BTN}
         ${tours}=    Evaluate    ${tours} + 1
         ${statut}=    Get Text    ${BANNER_STATUS}
         Log    Après ${tours} clic(s) : ${statut}
     END
     Element Text Should Be    ${BANNER_STATUS}    1 of 4

# Application: tester plusieurs combinaisons categorie+tri avec boucles imbriquées
 Categories Et Tri Complètes
     FOR    ${cat}    IN    @{CATEGORIES}
         ${locator}=    Set Variable    xpath://label[contains(normalize-space(.),'${cat}')]//input[@type='checkbox']
         Select Checkbox    ${locator}
         FOR    ${option}    IN    @{SORT_OPTIONS}
             Select From List By Label    ${SORT_LIST}    ${option}
             ${prices}=    Get Prices As Numbers
             Log    ${cat} - ${option} - ${prices}
         END
         Unselect Checkbox    ${locator}
     END