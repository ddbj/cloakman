<#import "footer.ftl" as loginFooter>

<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
  <!DOCTYPE html>

  <html class="${properties.kcHtmlClass!}" lang="${lang}"<#if realm.internationalizationEnabled> dir="${(locale.rtl)?then('rtl','ltr')}"</#if>>
    <head>
      <meta charset="utf-8">
      <meta name="robots" content="noindex, nofollow">

      <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
          <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
      </#if>

      <title>${msg("loginTitle",(realm.displayName!''))}</title>
      <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />

      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">

      <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
          <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
      </#if>

      <style>
        #DDBJ_CommonHeader {
          ul {
            padding: 0;

            li {
              list-style-type: none;
            }
          }
        }
      </style>

      <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
          <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
      </#if>

      <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
          <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
      </#if>

      <script type="importmap">
        {
          "imports": {
            "rfc4648": "${url.resourcesCommonPath}/vendor/rfc4648/rfc4648.js"
          }
        }
      </script>

      <script src="${url.resourcesPath}/js/menu-button-links.js" type="module"></script>

      <#if scripts??>
        <#list scripts as script>
          <script src="${script}" type="text/javascript"></script>
        </#list>
      </#if>

      <script type="module">
        import { startSessionPolling } from "${url.resourcesPath}/js/authChecker.js";

        startSessionPolling(
          "${url.ssoLoginInOtherTabsUrl?no_esc}"
        );
      </script>

      <#if authenticationSession??>
        <script type="module">
          import { checkAuthSession } from "${url.resourcesPath}/js/authChecker.js";

          checkAuthSession(
            "${authenticationSession.authSessionIdHash}"
          );
        </script>
      </#if>
    </head>

    <body class="${properties.kcBodyClass!}">
      <script src="https://www.ddbj.nig.ac.jp/assets/js/ddbj_common_framework.js" id="DDBJ_common_framework" data-bottom-menu="false" data-footer="false"></script>

      <div class="mx-auto my-5" style="max-width: 500px">
        <img src="${url.resourcesPath}/img/logo.png" alt="DDBJ - DNA Data Bank of Japan">

        <div class="mt-3 border-top border-4 border-primary shadow-lg p-3">
          <header class="${properties.kcFormHeaderClass!}">
            <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
              <div class="${properties.kcLocaleMainClass!}" id="kc-locale">
                <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">
                  <div id="kc-locale-dropdown" class="menu-button-links ${properties.kcLocaleDropDownClass!}">
                    <button tabindex="1" id="kc-current-locale-link" aria-label="${msg("languages")}" aria-haspopup="true" aria-expanded="false" aria-controls="language-switch1">${locale.current}</button>
                    <ul role="menu" tabindex="-1" aria-labelledby="kc-current-locale-link" aria-activedescendant="" id="language-switch1" class="${properties.kcLocaleListClass!}">
                      <#assign i = 1>
                      <#list locale.supported as l>
                        <li class="${properties.kcLocaleListItemClass!}" role="none">
                          <a role="menuitem" id="language-${i}" class="${properties.kcLocaleItemClass!}" href="${l.url}">${l.label}</a>
                        </li>
                        <#assign i++>
                      </#list>
                    </ul>
                  </div>
                </div>
              </div>
            </#if>

            <#if !(auth?has_content && auth.showUsername() && !auth.showResetCredentials())>
              <#if displayRequiredFields>
                <div class="${properties.kcContentWrapperClass!}">
                  <div class="${properties.kcLabelWrapperClass!} subtitle">
                    <span class="subtitle"><span class="required">*</span> ${msg("requiredFields")}</span>
                  </div>

                  <div class="col-md-10">
                    <h1 id="kc-page-title"><#nested "header"></h1>
                  </div>
                </div>
              <#else>
                <h1 class="fs-3 mb-3"><#nested "header"></h1>
              </#if>
            <#else>
              <#if displayRequiredFields>
                <div class="${properties.kcContentWrapperClass!}">
                  <div class="${properties.kcLabelWrapperClass!} subtitle">
                    <span class="subtitle"><span class="required">*</span> ${msg("requiredFields")}</span>
                  </div>
                  <div class="col-md-10">
                    <#nested "show-username">

                    <div id="kc-username" class="${properties.kcFormGroupClass!}">
                      <label id="kc-attempted-username">${auth.attemptedUsername}</label>

                      <a id="reset-login" href="${url.loginRestartFlowUrl}" aria-label="${msg("restartLoginTooltip")}">
                        <div class="kc-login-tooltip">
                          <i class="${properties.kcResetFlowIcon!}"></i>
                          <span class="kc-tooltip-text">${msg("restartLoginTooltip")}</span>
                        </div>
                      </a>
                    </div>
                  </div>
                </div>
              <#else>
                <#nested "show-username">

                <div id="kc-username" class="mb-3">
                  <div class="fs-3">${auth.attemptedUsername}</div>

                  <a id="reset-login" href="${url.loginRestartFlowUrl}" aria-label="${msg("restartLoginTooltip")}">
                    Change user
                  </a>
                </div>
              </#if>
            </#if>
          </header>

          <div id="kc-content">
            <div id="kc-content-wrapper">
              <#-- App-initiated actions should not see warning messages about the need to complete the action -->
              <#-- during login.                                         -->
              <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                <div class="alert alert-primary mt-3">
                  ${kcSanitize(message.summary)?no_esc}
                </div>
              </#if>

              <#nested "form">

              <#if auth?has_content && auth.showTryAnotherWayLink()>
                <form id="kc-select-try-another-way-form" action="${url.loginAction}" method="post">
                  <div class="${properties.kcFormGroupClass!}">
                    <input type="hidden" name="tryAnotherWay" value="on"/>
                    <a href="#" id="try-another-way" onclick="document.forms['kc-select-try-another-way-form'].requestSubmit();return false;">${msg("doTryAnotherWay")}</a>
                  </div>
                </form>
              </#if>

              <#nested "socialProviders">

              <#if displayInfo>
                <div id="kc-info" class="${properties.kcSignUpClass!}">
                  <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                    <#nested "info">
                  </div>
                </div>
              </#if>
            </div>
          </div>

          <@loginFooter.content/>
        </div>
      </div>
    </body>
  </html>
</#macro>
