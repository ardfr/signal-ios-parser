WITH thread_names AS (
    SELECT
        SearchableName.threadId AS thread_row_id,
        MIN(SearchableName.value) AS thread_display_name
    FROM SearchableName
    WHERE SearchableName.value IS NOT NULL
      AND TRIM(SearchableName.value) <> ''
    GROUP BY SearchableName.threadId
)
SELECT
    model_TSInteraction.uniqueThreadId AS thread_id,
    thread_names.thread_display_name AS thread_name,

    model_TSInteraction.id       AS message_row_id,
    model_TSInteraction.uniqueId AS message_unique_id,

    CASE model_TSInteraction.recordType
        WHEN 19 THEN 'Received'
        WHEN 21 THEN 'Sent'
        ELSE 'Other'
    END AS message_direction,

    datetime(model_TSInteraction.timestamp / 1000, 'unixepoch')           AS message_timestamp_utc,
    datetime(model_TSInteraction.receivedAtTimestamp / 1000, 'unixepoch') AS received_timestamp_utc,

    model_TSInteraction.body AS message_body,

    model_TSInteraction.callType AS call_type_value,
    CASE model_TSInteraction.callType
        WHEN 1 THEN 'Incoming Call'
        WHEN 2 THEN 'Outgoing Call'
        WHEN 3 THEN 'Incoming Missed Call'
        WHEN 7 THEN 'Incoming Declined Call'
        WHEN 8 THEN 'Outgoing Unanswered Call'
        ELSE NULL
    END AS call_type,

    model_OWSUserProfile.profileName          AS author_profile_name,
    model_OWSUserProfile.familyName           AS author_family_name,
    model_OWSUserProfile.recipientPhoneNumber AS author_phone_number,

    MessageAttachmentReference.sourceFilename        AS attachment_filename,
    MessageAttachmentReference.orderInMessage        AS attachment_order_in_message,
    Attachment.mimeType                              AS attachment_mime_type,
    Attachment.localRelativeFilePath                 AS attachment_local_path,
    lower(hex(Attachment.encryptionKey))             AS attachment_encryption_key,

    CallRecord.type AS callrecord_type_value,
    CASE CallRecord.type
        WHEN 0 THEN 'Voice Call'
        WHEN 1 THEN 'Video Call'
        WHEN 2 THEN 'Group Call'
        ELSE NULL
    END AS callrecord_type

FROM model_TSInteraction

LEFT JOIN model_TSThread
    ON model_TSThread.uniqueId = model_TSInteraction.uniqueThreadId

LEFT JOIN thread_names
    ON thread_names.thread_row_id = model_TSThread.id

LEFT JOIN model_OWSUserProfile
    ON model_TSInteraction.authorUUID = model_OWSUserProfile.recipientUUID

LEFT JOIN MessageAttachmentReference
    ON MessageAttachmentReference.ownerRowId = model_TSInteraction.id

LEFT JOIN Attachment
    ON MessageAttachmentReference.attachmentRowId = Attachment.id

LEFT JOIN CallRecord
    ON CallRecord.interactionRowId = model_TSInteraction.id
   AND CallRecord.threadRowId      = model_TSThread.id

ORDER BY
    model_TSInteraction.uniqueThreadId ASC,
    model_TSInteraction.timestamp ASC,
    MessageAttachmentReference.orderInMessage ASC;