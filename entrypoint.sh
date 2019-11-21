#!/bin/sh

lint() {
  awk '
    function report_trailing(line) {
      print "  " line ": trailing whitespace"
    }

    /[[:space:]]$/ {
      report_trailing(NR)
    }
  ' "${1}"
}

comment=""
status=0

for file in ${INPUT_FILES}; do
  if [ -d "$file" ]; then
    continue
  fi

  OUTPUT=$(lint "${file}")

  if [ -z "${OUTPUT}" ]; then
    continue
  fi
  echo "${file}:"
  echo "${OUTPUT}"
  status=1

  comment="${comment}<details><summary><code>${file}</code></summary>

\`\`\`
${OUTPUT}
\`\`\`

</details>"
done

if [ ${status} -eq 0 ]; then
  exit 0
fi

if [ "${GITHUB_EVENT_NAME}" = pull_request ]; then
  COMMENT_BODY="#### Issues with whitespace
${comment}

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`*"
  PAYLOAD=$(echo '{}' | jq --arg body "${COMMENT_BODY}" '.body = $body')
  COMMENTS_URL=$(jq -r .pull_request.comments_url <"${GITHUB_EVENT_PATH}")

  curl -sS \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H 'Content-Type: application/json' \
    -d "${PAYLOAD}" \
    "${COMMENTS_URL}" >/dev/null
fi

exit ${status}
