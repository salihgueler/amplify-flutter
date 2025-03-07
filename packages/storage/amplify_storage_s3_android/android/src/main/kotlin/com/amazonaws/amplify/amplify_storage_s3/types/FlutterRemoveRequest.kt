/*
 * Copyright 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package com.amazonaws.amplify.amplify_storage_s3.types

import com.amazonaws.amplify.amplify_core.exception.ExceptionMessages
import com.amazonaws.amplify.amplify_core.exception.InvalidRequestException
import com.amplifyframework.storage.StorageAccessLevel
import com.amplifyframework.storage.options.StorageRemoveOptions
import java.util.*

data class FlutterRemoveRequest(val request: Map<String, *>) {
    val key: String = request["key"] as String
    val options: StorageRemoveOptions = setOptions(request)

    private fun setOptions(request: Map<String, *>): StorageRemoveOptions {
        if (request["options"] != null) {
            val optionsMap = request["options"] as Map<String, *>
            val options: StorageRemoveOptions.Builder<*> = StorageRemoveOptions.builder()

            optionsMap.forEach { (optionKey, optionValue) ->
                when (optionKey) {
                    "accessLevel" -> {
                        val accessLevelStringOption = optionValue as String
                        val accessLevel: StorageAccessLevel? = StorageAccessLevel.values().find {
                            it.name == accessLevelStringOption.uppercase(
                                Locale.ROOT
                            )
                        }
                        options.accessLevel(accessLevel)
                    }
                    "targetIdentityId" -> {
                        options.targetIdentityId(optionValue as String?)
                    }
                }
            }
            return options.build()
        }
        return StorageRemoveOptions.defaultInstance()
    }

    companion object {
        private const val validationErrorMessage: String = "Remove request malformed."
        fun validate(request: Map<String, *>) {
            if (request["key"] !is String? || request["key"] == null) {
                throw InvalidRequestException(validationErrorMessage, ExceptionMessages.missingAttribute.format("key"))
            }
        }
    }
}
