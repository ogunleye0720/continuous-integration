pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }
    environment {
        SNAP_REPO = 'vprofile-snapshot'
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'password'
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '100.27.31.244'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
    }
    stages {
        stage('Build'){
            steps{
                sh 'mvn -DskipTests clean install'
            }
            post {
                success {
                    echo 'Archiving Artifact'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }

        }
        stage('UNIT TESTING'){
            steps {
                sh 'mvn test'
            }
        }
        stage('INTEGRATION TEST'){
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }
        stage('CODE ANALYSIS WITH CHECKSTYLE'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }
        stage('CODE ANALYSIS with SONARQUBE') {
            environment {
                scannerHome = tool 'sonarscanner'
            }
            steps {
                withSonarQubeEnv('sonarserver') {
                sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                    -Dsonar.projectName=vprofile-repo \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=/var/lib/jenkins/workspace/vprofile-ci-pipeline/src/ \
                    -Dsonar.java.binaries=/var/lib/jenkins/workspace/vprofile-ci-pipeline/target/test-classes/com/visualpathit/account/controllerTest/ \
                    -Dsonar.junit.reportsPath=/var/lib/jenkins/workspace/vprofile-ci-pipeline/target/surefire-reports/ \
                    -Dsonar.jacoco.reportsPath=/var/lib/jenkins/workspace/vprofile-ci-pipeline/target/jacoco.exec/ \
                    -Dsonar.java.checkstyle.reportPaths=/var/lib/jenkins/workspace/vprofile-ci-pipeline/target/checkstyle-result.xml
                    '''
                }
            }   
        }  
    }
}
