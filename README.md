# Travel Buddy - AI Agent (Vertex AI Agent Builder & Flask)

## Overview

This project implements a "Travel Buddy" conversational AI agent, following the principles and architecture outlined in the Google Codelab: [Building AI Agents with Vertex AI Agent Builder](https://codelabs.developers.google.com/devsite/codelabs/building-ai-agents-vertexai?hl=en).

The application consists of:

1. **Vertex AI Agent (Dialogflow CX)**: The core conversational agent built using Google Cloud's Vertex AI Agent Builder. This agent is designed to assist users with travel planning, such as discovering destinations, planning itineraries, and answering travel-related queries.
2. **Flask Web Application (`app.py`)**: A Python backend that serves a simple HTML frontend.
3. **HTML Frontend (`templates/index.html`)**: This page embeds the Dialogflow Messenger component, allowing users to interact with the Vertex AI Agent directly from their web browser.
4. **Docker Containerization (`Dockerfile`)**: The application is containerized using Docker for consistent deployment.
5. **Deployment Script (`deploy.sh`)**: An interactive shell script to simplify deployment to Google Cloud Run.

## Core Components & Relation to Codelab

* **Vertex AI Agent (Dialogflow CX)**:
  * This is the "brain" of the chatbot, created as described in Sections 2, 3, and 4 of the Codelab.
  * It involves defining the agent's purpose, creating playbooks (like "Info Agent"), setting goals, instructions, and potentially attaching datastores for grounding.
  * The specific agent used by this web application is identified by the `project-id` and `agent-id` in `templates/index.html`.

* **Flask Application (`app.py`)**:
  * Corresponds to the web server component discussed in Section 5 of the Codelab.
  * Its primary role is to serve the `index.html` file.
  * Runs on port 8080 by default.

* **HTML Frontend (`templates/index.html`)**:
  * This file contains the HTML structure and the crucial `<df-messenger>` snippet obtained after publishing the agent in Dialogflow (as shown in Section 5 of the Codelab).
  * It uses placeholder values `YOUR_GCP_PROJECT_ID` and `YOUR_DIALOGFLOW_AGENT_ID`. You **MUST** replace these with your actual Project ID and Agent ID from your Dialogflow agent configuration.

* **Dockerfile (`Dockerfile`)**:
  * Used to package the Flask application into a container image, as detailed in Section 5 of the Codelab.
  * It sets up the Python environment, copies application files, installs dependencies, and specifies the command to run `app.py`.

* **Deployment Script (`deploy.sh`)**:
  * This script automates the steps mentioned at the end of Section 5 of the Codelab (building the Docker image, pushing to Google Container Registry, and deploying to Cloud Run). It provides a user-friendly menu for these operations.

* **Requirements (`requirements.txt`)**:
  * Lists `Flask` as a dependency, necessary for `app.py`.

## Prerequisites

* A Google Cloud Project with billing enabled.
* Vertex AI Agent Builder and Dialogflow API enabled in your GCP project.
* An AI Agent created in Vertex AI Agent Builder (Dialogflow CX).
* Python 3.9 or higher.
* pip (Python package installer).
* Docker (ensure Docker is installed and running).
* Google Cloud SDK (`gcloud`) initialized and authenticated.

## Getting Started / Local Development

1. **Clone the repository (if applicable) or ensure you have all project files.**
2. **Install dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

3. **Configure Dialogflow Messenger (IMPORTANT):**
    Open `templates/index.html`. You **MUST** update the placeholder `project-id` (`YOUR_GCP_PROJECT_ID`) and `agent-id` (`YOUR_DIALOGFLOW_AGENT_ID`) attributes in the `<df-messenger>` tag to match your specific Dialogflow agent's details.

    ```html
    <df-messenger
      project-id="YOUR_GCP_PROJECT_ID"  <!-- Replace with your agent's project ID -->
      agent-id="YOUR_DIALOGFLOW_AGENT_ID"    <!-- Replace with your agent's ID -->
      language-code="en"
      max-query-length="-1">
      <df-messenger-chat-bubble
        chat-title="Travel Buddy">
      </df-messenger-chat-bubble>
    </df-messenger>
    ```

4. **Run the Flask application:**

    ```bash
    python app.py
    ```

    The application will be accessible at `http://localhost:8080`. You should see the webpage with the chat bubble in the bottom right corner.

## Building the Docker Image

To build the Docker image locally:

```bash
docker build -t travel-buddy .
```

For Cloud Run, it's often recommended to build for `linux/amd64`:

```bash
docker build --platform linux/amd64 -t travel-buddy .
```

## Deployment to Google Cloud Run

The `deploy.sh` script automates deployment:

1. **Make the script executable:**

    ```bash
    chmod +x deploy.sh
    ```

2. **Run the script:**

    ```bash
    ./deploy.sh
    ```

    Follow the on-screen prompts. For a full initial deployment or after making changes to the application code or `Dockerfile`, choose **option 1) Run full deployment workflow**. The script will guide you through:
    * Prerequisite checks.
    * Configuration (GCP Project ID, Service Name, Region).
    * Docker image build and tag.
    * Pushing the image to Google Container Registry (GCR).
    * Enabling required GCP services.
    * Deploying to Cloud Run.

## File Structure

```text
.
├── app.py                # Flask application (serves index.html)
├── Dockerfile            # Docker build instructions
├── deploy.sh             # Interactive deployment script for Google Cloud Run
├── requirements.txt      # Python dependencies (Flask)
├── templates/
│   └── index.html        # Frontend HTML with Dialogflow Messenger integration
└── README.md             # This file: Project overview and instructions
```
