---
title: "Platform Engineering: Overview"
date: 2024-07-14T12:00:00+00:00
author: sirius
draft: false
lightgallery: true
---

In this article, I will discuss the role of platform engineering in the software development lifecycle, its motivations, and tasks, and describe several approaches and examples for building your own platform.

First, it is essential to provide a disclaimer: if your company consists of a single team, if it is a small company, or if it is a startup, then platform engineering may not be suitable for you. Platform engineering requires dedicated resources and personnel focused exclusively on these tasks due to the scope involved.

This unit within your company should conduct research, perform continuous analysis, and develop solutions that will be used by all developers and impact the business. So, what tasks are currently set before the platform engineering team? To understand this, we need to look at the history of this field's emergence.

### The Evolution of Platform Engineering

To understand why platform engineering has become important, we need to look at its development over the past 20-25 years. During this period, there has been a transition from working with bare-metal servers to cloud solutions. Although cloud services are more expensive, they offer the flexibility that is a key feature of modern systems and development approaches.

Initially, there were physical servers (bare-metal) managed by system operators or system administrators. SysOps tasks included monitoring and maintaining systems, managing infrastructure, performing backups, applying updates and patches, and supporting users. Their role was particularly crucial in companies using bare-metal servers, but with the transition to cloud platforms, this role became less significant.

Developers have always aimed to automate their activities by creating build systems and infrastructure automation scripts to simplify routine procedures. Gradually, tools emerged that generalized the experience of such automation. Alongside these tools, specialists emerged to work with them. Simultaneously, Agile methodologies, requiring flexibility and frequent releases, began to be actively implemented in development. At the intersection of these trends, DevOps practices emerged — the automation of routine development tasks to increase flexibility. The first DevOps conference took place in 2009.

Of course, DevOps wasn't the only significant idea. In the early 2000s, Google developed the approach of Site Reliability Engineering (SRE). The tasks of SRE involved developing methods for building reliable and scalable systems. In 2016, Google published a book dedicated to the tasks of SRE. Before this, information about SRE was presented only fragmentarily at conferences. Since the book's release, SRE practices have been adopted by many companies.

These changes in approaches and tools led to the creation of a new discipline — platform engineering. This discipline focuses on building and maintaining internal platforms for developing and operating applications, ensuring a high degree of automation, flexibility, and scalability.

It's important to note that, on the one hand, there are methods for automation, resilience, scalability, and observability of systems. On the other hand, there are tools, processes, and infrastructure (cloud or bare-metal). Additionally, there is responsibility that must be properly distributed to achieve common goals.

## The Implementation of Platform Engineering

Since platform engineering is a relatively new field (emerging in the early 2020s), its implementation is likely to occur in an already established company. It is probable that the company already uses cloud resources or has some bare-metal servers. In this context, it is necessary to start defining the responsibilities between infrastructure and developers, which will be assigned to the platform engineering team.

This aligns with the primary development approach, where general-purpose tools (Kubernetes, cloud services, databases, CI/CD) are used to create specific abstractions that solve particular tasks. For example, the tasks of a Kubernetes cluster involve orchestration, but by implementing custom solutions, we can achieve effective management of our services and ensure their reliable performance with defined SLA/SLO/SLI.

I can recommend relying on the Lean approach in development and strict Change Management. Here are the steps for effective implementation:

1. **Identifying Value and Needs**: Understand who our users and consumers are and what value our platform creates for them as a product. For developers, this may involve simplifying delivery, improving observability, and providing clear abstractions. For the business, it focuses on reliability and cost efficiency. Additionally, we may be users of our own platform, practicing "dogfooding."
2. **Value Stream Mapping**: Analyze current processes to understand their structure and identify possible losses. This helps to understand how processes look now and what types of losses (e.g., redundant actions, waiting times, defects) can be eliminated.
3. **Creating Flow**: Minimize losses and implement automation wherever possible. This is the main stage where tools are developed and configured. What has been created becomes the responsibility of the platform engineering team.
4. **Continuous Improvement**: After a specific area is allocated to the platform engineering team, it is included in the continuous improvement process. Constantly improving processes and tools helps maintain high quality and efficiency.
5. **Team Involvement and Training**: Train the team to understand the necessary technical skills and the correct use of the platform. Developers need to be taught how to properly use the new platform, as abstractions and tools may be new to them.
6. **Monitoring and Evaluation**: Evaluate changes in terms of metric improvements. It is important to understand that improving some metrics may negatively affect others, so it is necessary to regularly monitor and analyze data to adjust the strategy.

Implementing these steps ensures that platform engineering is integrated effectively into the existing company structure, providing value to both developers and the business while maintaining high standards of efficiency and reliability.

We also need a clear change management process involving other developers and the business. Combining this approach with Lean methodology enhances the quality of the team's work. Since the value identification and assessment stage has already been completed, we can now focus on the change management process, detailing approaches to steps 3 and 4.

1. **Change Planning**: Describe how the changes will be implemented, specifying responsible parties, timelines, and expected outcomes.
2. **Change Discussion**: Since changes will be implemented by developers, it's crucial to discuss them with the developers. If there are many developers in the company, use focus groups to understand how they can implement the changes. This can include creating RFCs, conducting meetings, and presentations.
3. **Support During Change Implementation**: During the implementation phase, ensure comprehensive support for developers who may encounter issues. It's essential to monitor that the metrics evaluating the quality of developers' work do not deteriorate.

This plan allows for changes to be made where they are needed and in a way that is most beneficial for developers, the business, and all involved parties. Facilitation is essential to ensure that developers understand the principles behind the platform's abstractions. Any abstraction can have leaks, so it's impossible to hide everything behind interfaces. Developers must be involved in shaping the platform and understand how it works.

## Examples

In this chapter, sections with specific examples are provided, such as deployment, monitoring, and resource management.

### Deployment

Let's assume we already have a company with multiple deployment approaches, and we want to standardize the deployment process. Teams might use different methods, deploying as containers, lambdas, on bare-metal servers, or in Kubernetes.

1. **Defining the Value of Deployment**:
    - The value lies in the reliable deployment of code, which enhances business metrics. It also simplifies resource management, allowing separation of infrastructure configurations from product configurations, thereby reducing cognitive load on developers.
    - However, changing the execution environment can lead to unforeseen delays and errors, so we must analyze metrics such as error rates and P99 latency.
2. **Current Value Stream**:
    1. The developer creates a service image, typically using Docker.
    2. The developer writes the configuration for production deployment, specifying required resources, hardware parameters, resource quantities, and tracing parameters.
    3. The developer manually applies the configuration to multiple clusters. This could be deployment through containers to a cloud environment (e.g., ECS) or to a standalone machine via Docker Compose.
3. **Modifying the Value Stream for Deployment Optimization**:
    1. **Tools**:
        - Decide which tools to use: Kubernetes (or another orchestrator), Helm charts for defining basic service configurations, GitHub Actions for CI, ArgoCD for CD, Vault for secret management, and ETCD for configurations.
        - Secrets and configurations will be delivered to the Kubernetes cluster via operators from Vault and ETCD.
    2. **Developer Requirements**:
        - Describe the requirements for developers to integrate their services into the developed methodology. For example, each service should include a Makefile in the repository root, parameters in `service.yaml`, and use a standard Helm chart.
    3. **Engagement and Training**:
        - Discuss the implementation plan with developers and create a Minimum Viable Product (MVP) to demonstrate the process.
        - Conduct training sessions for developers on using new tools and configurations.
    4. **Implementation Plan**:
        - Define timelines, success metrics, responsibilities, and expectations. Establish SLAs for deployment and monitoring.
        - Set deadlines for implementing changes and guarantee support during the transition process.
    5. **Support and Improvement**:
        - Provide support to developers during the transition to new tools and configurations. Collect feedback and make necessary adjustments on the fly.
        - Use agile methodologies for continuous improvement of the deployment system.
4. **Educational Materials and Support**:
    - After implementation, gather and distribute educational materials such as documentation, instructions, and video tutorials.
    - Set up support processes, such as chatbots, messaging channels, and designate responsible support personnel.
5. **Evaluation and Improvement**:
    - Assess metrics such as the number of successful deployments, average deployment time, and the number of incidents post-deployment.
    - Conduct user surveys to gather feedback.
    - Analyze bottlenecks and make necessary improvements. Collect data on system stability and user satisfaction.

This approach helps create a reliable and standardized deployment system that minimizes risks and enhances team efficiency.

### Monitoring

Let's assume we already have a company with multiple monitoring approaches, and we want to standardize this process. Teams might use different tools and methods for monitoring, such as Prometheus, CloudWatch, Nagios, or the ELK Stack.

1. **Defining the Value of Monitoring**:
    - The value lies in reliably and timely detecting and notifying about issues, which minimizes downtime and optimizes service performance. It also simplifies resource management and reduces cognitive load on developers and operators.
    - We need to analyze metrics such as uptime, response time, error rate, and P99 latency to evaluate the effectiveness of changes and promptly respond to emerging problems.
2. **Current Value Stream**:
    1. A developer or operator sets up monitoring for their services. This might include creating and configuring metrics, alerts, and dashboards.
    2. The developer manually adds monitoring configurations to the system, specifying necessary parameters such as target nodes, ports, and metrics.
    3. Configurations are applied manually or through CI/CD tools, and metrics start being collected and displayed on dashboards. Alerts are set up to notify responsible parties.
3. **Modifying the Value Stream for Monitoring Optimization**:
    1. **Tools**:
        - Define a set of tools for standardizing monitoring: Prometheus for metrics collection, Grafana for visualization, Alertmanager for notifications management, Loki for log collection, and Thanos for long-term data storage.
        - Configurations and secrets will be stored and managed using Vault and ConfigMap/Secrets in Kubernetes.
    2. **Requirements for Developers and Operators**:
        - Describe the requirements for developers to integrate their services into the monitoring system. For example, metrics should be exported in Prometheus format, and logging should be centralized through Loki.
        - Create standard configuration templates for Prometheus and Grafana, which can be used for new services.
    3. **Engagement and Training**:
        - Discuss the implementation plan with developer and operator teams. Create an MVP (Minimum Viable Product) to demonstrate the process.
        - Conduct training for users to explain how to use new tools and configurations.
    4. **Implementation Plan**:
        - Define timelines, success metrics, responsibilities, and expectations. Establish SLAs for monitoring and notifications.
        - Set deadlines for implementing changes and ensure support during the transition process.
    5. **Support and Improvement**:
        - Provide support to users during the transition to new tools and configurations. Collect feedback and make necessary adjustments on the fly.
        - Use agile methodologies for continuous improvement of the monitoring system.
4. **Educational Materials and Support**:
    - After implementation, gather and distribute educational materials such as documentation, instructions, and video tutorials.
    - Set up support processes, such as chatbots, messaging channels, and designate responsible support personnel.
5. **Evaluation and Improvement**:
    - Assess metrics such as the number of incidents, mean time to recovery (MTTR), and metric stability.
    - Conduct user surveys to gather feedback.
    - Analyze bottlenecks and make necessary improvements. Collect data on system stability and user satisfaction.

This approach helps create a reliable and standardized monitoring system that minimizes risks and enhances team efficiency.

### Resource Management

We aim to reduce cloud costs, optimize the use of resources such as databases, caches, and underutilized Kubernetes nodes, and replace them with more cost-effective alternatives. Additionally, we need to more accurately define requests and limits for Kubernetes workloads.

1. **Defining the Value of Resource Optimization**:
    - Reduce cloud service costs and optimize resource usage.
    - Improve application performance by correctly allocating resources.
    - Reduce cognitive load on developers and operators by automating the identification and allocation of necessary resources.
    - Determine the cost of cloud services for each specific department.
2. **Current Value Stream**:
    1. Developers and operators create resources such as databases, caches, and Kubernetes nodes with assumed parameters.
    2. Resources are used by applications, but their efficiency and utilization are rarely monitored.
    3. Underutilized resources continue to consume resources and increase cloud costs.
3. **Modifying the Value Stream for Resource Optimization**:
    1. **Tools**:
        - Use tools for monitoring and analyzing resource utilization, such as Prometheus, Grafana, and Kubernetes Metrics Server.
        - Implement automated solutions for resource analysis and optimization, such as KubeCost or CloudHealth for cost and utilization analysis.
    2. **Analysis Process**:
        - Collect data on the usage of all resources, including databases, caches, and Kubernetes nodes.
        - Analyze data to identify underutilized resources and determine their current utilization.
        - Identify possible alternatives and optimization strategies, such as downscaling, replacing with more cost-effective options, or reorganizing resources.
    3. **Optimizing Kubernetes Workloads**:
        - Determine the current requests and limits for all workloads in the Kubernetes cluster.
        - Use historical data to determine optimal values for requests and limits for each workload.
        - Implement automated recommendations and adjustments through tools such as Vertical Pod Autoscaler and Resource Quotas.
    4. **Engagement and Training**:
        - Discuss the implementation plan with developer and operator teams. Create a Minimum Viable Product (MVP) to demonstrate the process.
        - Conduct training sessions for users on using new tools and configurations.
    5. **Implementation Plan**:
        - Define timelines, success metrics, responsibilities, and expectations. Establish SLAs for monitoring and resource management.
        - Set deadlines for implementing changes and ensure support during the transition process.
    6. **Support and Improvement**:
        - Provide support to developers and operators during the transition to new tools and configurations. Collect feedback and make necessary adjustments on the fly.
        - Use agile methodologies for continuous improvement of resource management.
4. **Educational Materials and Support**:
    - After implementation, gather and distribute educational materials such as documentation, instructions, and video tutorials.
    - Set up support processes, such as chatbots, messaging channels, and designate responsible support personnel.
5. **Evaluation and Improvement**:
    - Assess metrics such as the number of optimized resources, reduction in cloud costs, and improvement in resource utilization.
    - Conduct user surveys to gather feedback.
    - Analyze bottlenecks and make necessary improvements. Collect data on system stability and user satisfaction.

This approach helps create a reliable and standardized resource management system that minimizes costs and improves resource utilization efficiency.

## Conclusion

Platform engineering is an effective approach for creating simple abstractions that help developers spend more time on business logic and enable businesses to achieve results faster while understanding the relationship between infrastructure costs and efficiency.

Platform engineering has evolved from combining the concepts of SysOps, DevOps, and SRE. In this evolution, some responsibilities from these disciplines have been shifted to developers as the owners of services.

Implementing a platform should be gradual and considerate of the requirements of developers, business needs, and best practices in the field. The Lean framework and Change Management can be utilized for this purpose.

Depending on the type of changes, different actions and tools may be required, but the overall approach remains the same.

Good luck in your efforts to create a better platform for both developers and the business!
