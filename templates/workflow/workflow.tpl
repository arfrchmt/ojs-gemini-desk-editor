{**
 * templates/workflow/workflow.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * Display the workflow tab structure.
 *}
{extends file="layouts/backend.tpl"}

{block name="page"}
	<pkp-header :is-one-line="true" class="pkpWorkflow__header">
		<h1 class="pkpWorkflow__identification">
			<badge
				v-if="submission.status === getConstant('STATUS_PUBLISHED')"
				class="pkpWorkflow__identificationStatus"
				:is-success="true"
			>
				{translate key="publication.status.published"}
			</badge>
			<badge
				v-else-if="submission.status === getConstant('STATUS_SCHEDULED')"
				class="pkpWorkflow__identificationStatus"
				:is-primary="true"
			>
				{translate key="publication.status.scheduled"}
			</badge>
			<badge
				v-else-if="submission.status === getConstant('STATUS_DECLINED')"
				class="pkpWorkflow__identificationStatus"
				:is-warnable="true"
			>
				{translate key="common.declined"}
			</badge>
			<span class="pkpWorkflow__identificationId">{{ submission.id }}</span>
			<span class="pkpWorkflow__identificationDivider">/</span>
			<span class="pkpWorkflow__identificationAuthor">
				{{ currentPublication.authorsStringShort }}
			</span>
			<span class="pkpWorkflow__identificationDivider">/</span>
			<span class="pkpWorkflow__identificationTitle">
				{{ localizeSubmission(currentPublication.fullTitle, currentPublication.locale) }}
			</span>
		</h1>
		<template slot="actions">
			<pkp-button
				v-if="submission.status === getConstant('STATUS_PUBLISHED')"
				element="a"
				:href="submission.urlPublished"
			>
				{{ __('common.view') }}
			</pkp-button>
			<pkp-button
				v-else-if="submission.status !== getConstant('STATUS_PUBLISHED') && submission.stageId >= getConstant('WORKFLOW_STAGE_ID_EDITING')"
				element="a"
				:href="submission.urlPublished"
			>
				{translate key="common.preview"}
			</pkp-button>
			{if $submissionPaymentsEnabled}
				<dropdown
					class="pkpWorkflow__submissionPayments"
					label="{translate key="common.payments"}"
				>
					<pkp-form class="pkpWorkflow__submissionPaymentsForm" v-bind="components.{$smarty.const.FORM_SUBMISSION_PAYMENTS}" @set="set">
				</dropdown>
			{/if}
			{if $canAccessEditorialHistory}
				<pkp-button
					ref="activityButton"
					@click="openActivity"
				>
					{translate key="editor.activityLog"}
				</pkp-button>
			{/if}
			<pkp-button
				ref="library"
				@click="openLibrary"
			>
				{translate key="editor.submissionLibrary"}
			</pkp-button>
		</template>
	</pkp-header>
	<tabs default-tab="workflow" :track-history="true">
		<tab id="workflow" label="{translate key="manager.workflow"}">
			<script type="text/javascript">
				// Initialize JS handler.
				$(function() {ldelim}
					$('#submissionWorkflow').pkpHandler(
						'$.pkp.pages.workflow.WorkflowHandler'
					);
				{rdelim});
			</script>

			<div id="submissionWorkflow" class="pkp_submission_workflow">
				{include file="controllers/notification/inPlaceNotification.tpl" notificationId="workflowNotification" requestOptions=$workflowNotificationRequestOptions}
				{capture assign=submissionProgressBarUrl}{url op="submissionProgressBar" submissionId=$submission->getId() stageId=$requestedStageId contextId="submission" escape=false}{/capture}
				{load_url_in_div id="submissionProgressBarDiv" url=$submissionProgressBarUrl}
<!-- BANNER TOMBOL GEMINI DESK SCREENING -->
<div style="background: #ffffff; border: 1.5px solid #22c55e; border-left: 5px solid #16a34a; border-radius: 6px; padding: 12px 18px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
	<div style="display: flex; align-items: center;">
		<span style="font-size: 24px; margin-right: 12px;">🤖</span>
		<div>
			<strong style="color: #15803d; font-size: 14px; display: block;">Gemini Automated Desk Screener</strong>
			<span style="color: #64748b; font-size: 12px;">Validasi kepatuhan format & template jurnal sebelum mengirim naskah ke reviewer</span>
		</div>
	</div>
	{capture assign=geminiScreeningUrl}{url router=$smarty.const.ROUTE_PAGE page="geminiDeskScreenerHandler" op="runScreening" submissionId=$submission->getId()}{/capture}
	<button type="button" class="pkp_button" style="background: #16a34a; color: #ffffff; font-weight: bold; border: none; padding: 9px 18px; border-radius: 4px; cursor: pointer;" onclick="execDeskScreening('{$geminiScreeningUrl|escape:"javascript"}', '{$submission->getId()|escape:"javascript"}')">
		⚡ Jalankan AI Desk Screening
	</button>
</div>

<!-- MODAL POPUP HASIL SCREENING -->
<div id="geminiScreeningModal" style="display:none; position: fixed; z-index: 99999; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5);">
	<div style="background-color: #ffffff; margin: 4% auto; padding: 25px; border-radius: 8px; width: 65%; max-width: 850px; box-shadow: 0 5px 20px rgba(0,0,0,0.3); font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
		<div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #e2e8f0; padding-bottom: 12px;">
			<h3 style="margin: 0; color: #1e293b; font-size: 18px;">📊 Hasil Validasi Template & Desk Screening</h3>
			<span style="font-size: 24px; font-weight: bold; cursor: pointer; color: #64748b;" onclick="$('#geminiScreeningModal').hide()">&times;</span>
		</div>
		<div id="geminiModalBody" style="padding: 20px 0; max-height: 480px; overflow-y: auto;"></div>
		<div style="border-top: 1px solid #e2e8f0; padding-top: 14px; text-align: right;">
			<button type="button" class="pkp_button" style="background: #64748b; color: #fff; padding: 7px 16px; border: none; border-radius: 4px; cursor: pointer;" onclick="$('#geminiScreeningModal').hide()">Tutup</button>
		</div>
	</div>
</div>

<script type="text/javascript">
function execDeskScreening(ajaxUrl, subId) {
	$('#geminiModalBody').html('<div style="text-align:center; padding: 40px;"><div style="font-size: 32px;">⏳</div><p style="font-size: 14px; color: #475569; margin-top: 10px;">Gemini AI sedang memvalidasi format dan metadata naskah...</p></div>');
	$('#geminiScreeningModal').show();

	$.ajax({
		url: ajaxUrl,
		type: "POST",
		dataType: "json",
		success: function(data) {
			if (data.status && data.report) {
				var rep = data.report;
				var scoreColor = rep.score >= 80 ? '#16a34a' : (rep.score >= 50 ? '#d97706' : '#dc2626');

				var html = '<div style="display: flex; justify-content: space-between; align-items: center; background: #f8fafc; padding: 15px; border-radius: 6px; margin-bottom: 18px; border: 1px solid #e2e8f0;">' +
					'<div><span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: bold;">Rekomendasi Keputusan</span>' +
					'<h4 style="margin: 4px 0 0 0; color: #0f172a; font-size: 16px;">' + rep.desk_decision + '</h4></div>' +
					'<div style="text-align: right;"><span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: bold;">Skor Template</span>' +
					'<div style="font-size: 24px; font-weight: 800; color: ' + scoreColor + ';">' + rep.score + ' / 100</div></div>' +
				'</div>';

				html += '<h4 style="font-size: 14px; color: #1e293b; margin: 15px 0 8px 0;">Checklist Kepatuhan Template:</h4>';
				html += '<table style="width: 100%; border-collapse: collapse; font-size: 13px; margin-bottom: 18px;">';
				html += '<tr style="background: #f1f5f9; text-align: left;"><th style="padding: 8px; border: 1px solid #cbd5e1;">Item Pemeriksaan</th><th style="padding: 8px; border: 1px solid #cbd5e1; width: 90px; text-align:center;">Status</th><th style="padding: 8px; border: 1px solid #cbd5e1;">Catatan</th></tr>';

				if (rep.evaluations) {
					for (var key in rep.evaluations) {
						var item = rep.evaluations[key];
						var pass = (item.status === 'Pass');
						var badge = pass ? '<span style="color: #16a34a; font-weight: bold;">✔ PASS</span>' : '<span style="color: #dc2626; font-weight: bold;">✖ FAIL</span>';
						var label = key.replace(/_/g, ' ').toUpperCase();
						html += '<tr>' +
							'<td style="padding: 8px; border: 1px solid #cbd5e1; font-weight: 600;">' + label + '</td>' +
							'<td style="padding: 8px; border: 1px solid #cbd5e1; text-align: center;">' + badge + '</td>' +
							'<td style="padding: 8px; border: 1px solid #cbd5e1; color: #475569;">' + (item.remarks || '-') + '</td>' +
						'</tr>';
					}
				}
				html += '</table>';

				if (rep.overall_feedback_for_author) {
					html += '<div style="background: #eff6ff; border-left: 4px solid #3b82f6; padding: 12px 16px; border-radius: 4px;">' +
						'<strong style="color: #1e40af; font-size: 13px; display: block; margin-bottom: 4px;">Catatan Siap Kirim ke Penulis:</strong>' +
						'<p style="margin: 0; color: #334155; font-size: 13px; line-height: 1.5;">' + rep.overall_feedback_for_author + '</p>' +
					'</div>';
				}

				$('#geminiModalBody').html(html);
			} else {
				$('#geminiModalBody').html('<div style="color: #dc2626; padding: 20px; text-align: center;"><strong>Gagal:</strong> ' + (data.message || 'Respons tidak valid.') + '</div>');
			}
		},
		error: function(xhr, status, err) {
			$('#geminiModalBody').html('<div style="color: #dc2626; padding: 20px; text-align: center;"><strong>Error:</strong> ' + err + '</div>');
		}
	});
}
</script>			

</div>
		</tab>
		{if $canAccessPublication}
			<tab id="publication" label="{translate key="submission.publication"}">
				{help file="editorial-workflow/publication" class="pkp_help_tab"}
				<div class="pkpPublication" ref="publication" aria-live="polite">
					<pkp-header class="pkpPublication__header" :is-one-line="false">
						<span class="pkpPublication__status">
							<strong>{{ statusLabel }}</strong>
							<span v-if="workingPublication.status === getConstant('STATUS_QUEUED') && workingPublication.id === currentPublication.id" class="pkpPublication__statusUnpublished">{translate key="publication.status.unscheduled"}</span>
							<span v-else-if="workingPublication.status === getConstant('STATUS_SCHEDULED')">{translate key="publication.status.scheduled"}</span>
							<span v-else-if="workingPublication.status === getConstant('STATUS_PUBLISHED')" class="pkpPublication__statusPublished">{translate key="publication.status.published"}</span>
							<span v-else class="pkpPublication__statusUnpublished">{translate key="publication.status.unpublished"}</span>
						</span>
						<span v-if="publicationList.length > 1" class="pkpPublication__version">
							<strong tabindex="0">{{ versionLabel }}</strong> {{ workingPublication.version }}
							<dropdown
								class="pkpPublication__versions"
								label="{translate key="publication.version.all"}"
								:is-link="true"
								submenu-label="{translate key="common.submenu"}"
							>
								<ul>
									<li v-for="publication in publicationList" :key="publication.id">
										<button
											class="pkpDropdown__action"
											:disabled="publication.id === workingPublication.id"
											@click="setWorkingPublicationById(publication.id)"
										>
											{{ publication.version }} /
											<template v-if="publication.status === getConstant('STATUS_QUEUED') && publication.id === currentPublication.id">{translate key="publication.status.unscheduled"}</template>
											<template v-else-if="publication.status === getConstant('STATUS_SCHEDULED')">{translate key="publication.status.scheduled"}</template>
											<template v-else-if="publication.status === getConstant('STATUS_PUBLISHED')">{{ publication.datePublished }}</template>
											<template v-else>{translate key="publication.status.unpublished"}</template>
										</button>
									</li>
								</ul>
							</dropdown>
						</span>
						{if $canPublish}
							<template slot="actions">
								<pkp-button
									v-if="workingPublication.status !== getConstant('STATUS_PUBLISHED') && submission.stageId >= getConstant('WORKFLOW_STAGE_ID_EDITING')"
									element="a"
									:href="workingPublication.urlPublished"
								>
									{translate key="common.preview"}
								</pkp-button>
								<pkp-button
									v-if="workingPublication.status === getConstant('STATUS_QUEUED')"
									ref="publish"
									@click="workingPublication.issueId ? openPublish() : openAssignToIssue()"
								>
									{{ submission.status === getConstant('STATUS_PUBLISHED') ? publishLabel : schedulePublicationLabel }}
								</pkp-button>
								<pkp-button
									v-else-if="workingPublication.status === getConstant('STATUS_SCHEDULED')"
									:is-warnable="true"
									@click="openUnpublish"
								>
									{translate key="publication.unschedule"}
								</pkp-button>
								<pkp-button
									v-else-if="workingPublication.status === getConstant('STATUS_PUBLISHED')"
									:is-warnable="true"
									@click="openUnpublish"
								>
									{translate key="publication.unpublish"}
								</pkp-button>
								<pkp-button
									v-if="canCreateNewVersion"
									ref="createVersion"
									@click="openCreateVersionPrompt"
								>
									{translate key="publication.createVersion"}
								</pkp-button>
							</template>
						{/if}
					</pkp-header>
					<div
						v-if="workingPublication.status === getConstant('STATUS_PUBLISHED')"
						class="pkpPublication__versionPublished"
					>
						{translate key="publication.editDisabled"}
					</div>
					<tabs class="pkpPublication__tabs" :is-side-tabs="true" :track-history="true" :label="currentPublicationTabsLabel">
						<tab id="titleAbstract" label="{translate key="publication.titleAbstract"}">
							<pkp-form v-bind="components.{$smarty.const.FORM_TITLE_ABSTRACT}" @set="set" />
						</tab>
						<tab id="contributors" label="{translate key="publication.contributors"}">
							<div id="contributors-grid" ref="contributors">
								<spinner></spinner>
							</div>
						</tab>
						{if $metadataEnabled}
							<tab id="metadata" label="{translate key="submission.informationCenter.metadata"}">
								<pkp-form v-bind="components.{$smarty.const.FORM_METADATA}" @set="set" />
							</tab>
						{/if}
						<tab v-if="supportsReferences" id="citations" label="{translate key="submission.citations"}">
							<pkp-form v-bind="components.{$smarty.const.FORM_CITATIONS}" @set="set" />
						</tab>
						{if $identifiersEnabled}
							<tab id="identifiers" label="{translate key="submission.identifiers"}">
								<pkp-form v-bind="components.{$smarty.const.FORM_PUBLICATION_IDENTIFIERS}" @set="set" />
							</tab>
						{/if}
						{if $canAccessProduction}
							<tab id="galleys" label="{translate key="submission.layout.galleys"}">
								<div id="representations-grid" ref="representations">
									<spinner></spinner>
								</div>
							</tab>
							<tab id="license" label="{translate key="publication.publicationLicense"}">
								<pkp-form v-bind="components.{$smarty.const.FORM_PUBLICATION_LICENSE}" @set="set" />
							</tab>
							<tab id="issue" label="{translate key="issue.issue"}">
								<pkp-form v-bind="components.{$smarty.const.FORM_ISSUE_ENTRY}" @set="set" />
							</tab>
						{/if}
						{call_hook name="Template::Workflow::Publication"}
					</tabs>
					<span class="pkpPublication__mask" :class="publicationMaskClasses">
						<spinner></spinner>
					</span>
				</div>
			</tab>
		{/if}
		{call_hook name="Template::Workflow"}
	</tabs>
{/block}
