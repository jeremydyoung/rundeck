package org.rundeck.app.authorization.domain

import com.dtolabs.rundeck.core.authorization.AuthContextProcessor
import groovy.transform.CompileStatic
import org.rundeck.core.auth.access.AuthorizedAccess
import org.rundeck.core.auth.access.AuthorizedResource
import org.springframework.beans.factory.annotation.Autowired

@CompileStatic
abstract class BaseAuthorizedAccess<D, A extends AuthorizedResource<D>>
    implements AuthorizedAccess<D, A> {


    @Autowired
    AuthContextProcessor rundeckAuthContextProcessor
}
