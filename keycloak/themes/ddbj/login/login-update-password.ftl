<#import "template.ftl" as layout>
<#import "password-commons.ftl" as passwordCommons>

<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-confirm'); section>
  <#if section = "header">
    ${msg("updatePasswordTitle")}
  <#elseif section = "form">
    <form id="kc-passwd-update-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
      <div class="mb-3">
        <label for="password-new" class="form-label">${msg("passwordNew")}</label>

        <div class="input-group" dir="ltr">
          <input type="password" id="password-new" name="password-new" class="form-control" autofocus autocomplete="new-password" aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>">
          <button class="btn btn-outline-secondary" type="button" aria-label="${msg('showPassword')}" aria-controls="password-new" data-password-toggle data-icon-show="${properties.kcFormPasswordVisibilityIconShow!}" data-icon-hide="${properties.kcFormPasswordVisibilityIconHide!}" data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-eye-fill" viewBox="0 0 16 16">
              <path d="M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0"/>
              <path d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8m8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7"/>
            </svg>
          </button>
        </div>

        <#if messagesPerField.existsError('password')>
          <span id="input-error-password" class="invalid-feedback" aria-live="polite">
            ${kcSanitize(messagesPerField.get('password'))?no_esc}
          </span>
        </#if>
      </div>

      <div class="mb-3">
        <label for="password-confirm" class="form-label">${msg("passwordConfirm")}</label>

        <div class="input-group" dir="ltr">
          <input type="password" id="password-confirm" name="password-confirm" class="form-control" autocomplete="new-password" aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>">
          <button class="btn btn-outline-secondary" type="button" aria-label="${msg('showPassword')}" aria-controls="password-confirm" data-password-toggle data-icon-show="${properties.kcFormPasswordVisibilityIconShow!}" data-icon-hide="${properties.kcFormPasswordVisibilityIconHide!}" data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-eye-fill" viewBox="0 0 16 16">
              <path d="M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0"/>
              <path d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8m8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7"/>
            </svg>
          </button>
        </div>

        <#if messagesPerField.existsError('password-confirm')>
          <span id="input-error-password-confirm" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
            ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
          </span>
        </#if>
      </div>

      <div class="mb-3">
        <@passwordCommons.logoutOtherSessions />
      </div>

      <#if isAppInitiatedAction??>
        <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}" />
        <button class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" type="submit" name="cancel-aia" value="true" />${msg("doCancel")}</button>
      <#else>
        <div class="d-grid">
          <input class="btn btn-primary" type="submit" value="${msg("doSubmit")}" />
        </div>
      </#if>
    </form>

    <script type="module" src="${url.resourcesPath}/js/passwordVisibility.js"></script>
  </#if>
</@layout.registrationLayout>
