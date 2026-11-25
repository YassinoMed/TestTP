*** Settings ***
Library    SeleniumLibrary
Library    String
Library    Collections

*** Variables ***
${BASE}              https://jstestingacademy.co.in/qa-apps/shopkart
${URL}               ${BASE}/index.html
${LOGIN_URL}         ${BASE}/login.html
${REGISTER_URL}      ${BASE}/register.html
${CART_URL}          ${BASE}/cart.html
${ORDERS_URL}        ${BASE}/orders.html
${BROWSER}           chrome
${USER}              qa.tester
${PASSWORD}          Passw0rd!

# --- Accueil ---
${SEARCH_INPUT}      xpath://input[@type='search' or contains(@placeholder,'earch')]
${SEARCH_BUTTON}     xpath://button[normalize-space()='Search']
${SORT_LIST}         xpath:(//select)[1]
${CLEAR_FILTERS}     xpath://*[self::button or self::a][normalize-space()='Clear all filters']
${CHK_ELECTRONICS}   xpath://label[contains(normalize-space(.),'Electronics')]//input[@type='checkbox']
${CHK_IN_STOCK}      xpath://label[contains(normalize-space(.),'In stock only')]//input[@type='checkbox']
${ADD_TO_CART_BTN}   xpath://button[contains(normalize-space(.),'Add to cart')]
${PRODUCT_PRICES}    xpath://*[contains(@class,'card')]//*[contains(@class,'price')]
${CART_LINK}         xpath://a[starts-with(normalize-space(.),'Cart')]

# --- Categories for loop testing ---
@{CATEGORIES}        Electronics    Fashion    Home    Books

# --- Sort options for loop testing ---
@{SORT_OPTIONS}      Relevance    Price: low to high    Price: high to low    Customer rating    Name A to Z

# --- Coupons for loop testing ---
@{COUPONS}           SAVE10    EXPIRED5    FAUX123

# --- Results expected for coupons ---
@{COUPON_RESULTS}    discount    expired     invalid

# --- Login / Register ---
${USERNAME_INPUT}    xpath://label[starts-with(normalize-space(.),'Username')]/following::input[1]
${PASSWORD_INPUT}    xpath://label[starts-with(normalize-space(.),'Password')]/following::input[1]
${LOGIN_BUTTON}      xpath://button[normalize-space()='Login']
${FULLNAME_INPUT}    xpath://label[starts-with(normalize-space(.),'Full name')]/following::input[1]
${EMAIL_INPUT}       xpath://label[starts-with(normalize-space(.),'Email')]/following::input[1]
${CONFIRM_INPUT}     xpath://label[starts-with(normalize-space(.),'Confirm password')]/following::input[1]
${TERMS_CHECKBOX}    xpath://input[@type='checkbox']
${CREATE_BUTTON}     xpath://button[normalize-space()='Create account']

# --- Checkout ---
${CHECKOUT_BTN}      xpath://*[self::a or self::button][contains(normalize-space(.),'Checkout')]
${PLACE_ORDER_BTN}   xpath://button[contains(normalize-space(.),'Place order')]
${NAME_FIELD}        xpath://label[contains(normalize-space(.),'Name')]/following::input[1]
${MOBILE_FIELD}      xpath://label[contains(normalize-space(.),'Mobile')]/following::input[1]
${CO_EMAIL_FIELD}    xpath://label[contains(normalize-space(.),'Email')]/following::input[1]
${RADIO_CARD}        xpath://label[contains(normalize-space(.),'Card')]
${RADIO_UPI}         xpath://label[contains(normalize-space(.),'UPI')]

# --- Carrousel ---
${BANNER_STATUS}     id:banner-status
${NEXT_BTN}          xpath://button[contains(@aria-label,'ext') or normalize-space()='›']
${PREV_BTN}          xpath://button[contains(@aria-label,'rev') or normalize-space()='‹']
${HIDDEN_SLIDES}     xpath://*[@aria-hidden='true']

# --- Coupon input ---
${COUPON_INPUT}      xpath://input[contains(@placeholder,'oupon') or contains(@id,'oupon')]
${COUPON_APPLY}      xpath://button[contains(normalize-space(.),'Apply')]
${EMPTY_CART_BTN}    xpath://button[contains(normalize-space(.),'Clear cart')]

*** Keywords ***
Open Shop
    [Documentation]    Ouvre le site avec un état propre (localStorage vidé).
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Execute Javascript    window.localStorage.clear()
    Reload Page

Close Shop
    Close All Browsers

Login Application
    [Arguments]    ${username}    ${password}
    Go To           ${LOGIN_URL}
    Input Text      ${USERNAME_INPUT}    ${username}
    Input Text      ${PASSWORD_INPUT}    ${password}
    Click Button    ${LOGIN_BUTTON}

Page Should Contain Ignoring Case
    [Arguments]    ${expected}
    ${body}=    Get Text    css:body
    ${body}=    Convert To Lower Case    ${body}
    ${expected}=    Convert To Lower Case    ${expected}
    Should Contain    ${body}    ${expected}

Add Product To Cart
    [Arguments]    ${index}=1
    Click Button    xpath:(//button[contains(normalize-space(.),'Add to cart')])[${index}]

Get Prices As Numbers
    [Documentation]    Retourne la liste des prix affichés, convertis en entiers.
    ${elements}=    Get WebElements    ${PRODUCT_PRICES}
    ${numbers}=     Create List
    FOR    ${el}    IN    @{elements}
        ${txt}=    Get Text    ${el}
        ${digits}=    Evaluate    int(re.sub(r'[^0-9]', '', $txt.split('\\n')[0]))    modules=re
        Append To List    ${numbers}    ${digits}
    END
    RETURN    ${numbers}

# --- Loop utility keywords ---

# Boucle pour tester toutes les options de tri
Apply Sort Options
    [Arguments]    ${sort_list}
    FOR    ${option}    IN    @{SORT_OPTIONS}
        Select From List By Label    ${sort_list}    ${option}
    END

# Boucle pour tester toutes les categories
Apply Category Filters
    [Arguments]    ${categories}
    FOR    ${cat}    IN    @{categories}
        Select Checkbox    xpath://label[contains(normalize-space(.),'${cat}')]//input[@type='checkbox']
    END
    # Reset: unselect all
    FOR    ${cat}    IN    @{categories}
        ${locator}=    Set Variable    xpath://label[contains(normalize-space(.),'${cat}')]//input[@type='checkbox']
        Unselect Checkbox    ${locator}
    END

# Boucle pour appliquer des coupons
Apply Coupons
    [Arguments]    ${coupons}    ${results}
    Add Product To Cart    1
    Go To    ${CART_URL}
    FOR    ${coupon}    ${attendu}    IN ZIP    ${coupons}    ${results}
        Input Text      ${COUPON_INPUT}    ${coupon}
        Click Button    ${COUPON_APPLY}
        Page Should Contain Ignoring Case    ${attendu}
    END

# Boucle WHILE avec limite de sécurité
Safe While Loop
    [Arguments]    ${condition}    ${max_iterations}
    ${compteur}=    Set Variable    0
    WHILE    ${compteur} < ${condition}    limit=${max_iterations}
        [Keyword]
    END

# Repeat Keyword N times
Repeat Keyword N Times
    [Arguments]    ${count}    ${keyword}    ${args}=
    Repeat Keyword    ${count} times    ${keyword}    ${args}