package org.rundeck.app.components.project;

import org.rundeck.core.projects.ProjectDataExporter;
import org.rundeck.core.projects.ProjectDataImporter;

public interface ProjectComponent extends ProjectDataExporter, ProjectDataImporter {
    /**
     * @return component identifier
     */
    String getName();

    /**
     * @return title text when displaying Import and Export options
     */
    default String getTitle() {
        return null;
    }

    /**
     * @return message code for title
     */
    default String getTitleCode() {
        return null;
    }

    /**
     * Project definition is deleted
     * @param name project name
     */
    default void projectDeleted(String name){

    }
}
