PROJECT_ID = nl-tech-app-creamos-mm
PROJECT_NR = 677665590444
#SERVICE_ACCOUNT_NAME = github-action@${PROJECT_ID}.iam.gserviceaccount.com
SERVICE_ACCOUNT_NAME = github-actions


connect_to_project:
	@gcloud config set project ${PROJECT_ID}

#===============================================================
# Worload Identitiy stuff
# gitlab-cicd@nl-tech-app-creamos-mm.iam.gserviceaccount.com
#===============================================================

create_service_account: connect_to_project
	gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
		--description="Service account for Github Actions CI/CD" \
		--display-name="${SERVICE_ACCOUNT_NAME}"


create_gihub_wif_pool:
	gcloud iam workload-identity-pools create github-wif-pool \
		--location="global" \
		--project="${PROJECT_ID}"

create_github_wif_provider:
	gcloud iam workload-identity-pools providers create-oidc github-wif-provider \
		--workload-identity-pool="github-wif-pool" \
		--location="global" \
		--issuer-uri="https://token.actions.githubusercontent.com" \
		--project="${PROJECT_ID}" \
		--attribute-mapping="attribute.actor=assertion.actor,google.subject=assertion.sub,attribute.repository=assertion.repository"


bind_github_wif_provider:
	gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
		--role="roles/iam.workloadIdentityUser" \
		--member="principalSet://iam.googleapis.com/projects/${PROJECT_NR}/locations/global/workloadIdentityPools/github-wif-pool/*"
