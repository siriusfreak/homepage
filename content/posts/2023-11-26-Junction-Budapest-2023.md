---
title: "Junction Budapest 2023: Feline Guard"
date: 2023-11-26T12:00:00+00:00
author: sirius
draft: false
lightgallery: true
---

{{< youtube id="-ygvH3hCjtE" title="Junction Budapest 2023: Feline Guard" >}}

Every six months, the volume of Deep Fake content doubles. With each iteration, these fakes become more sophisticated and convincing, posing significant challenges in detection and prevention. To address this escalating issue, we have embarked on a comprehensive project aimed at developing a robust solution for Deep Fake detection and mitigation.

{{< figure src="https://images.siriusfrk.me/posts/2023-11-26-Junction-Budapest-2023/1.png" caption="" >}}

## Project Overview

Our project encompasses several key tasks:

1. **Analyzing Current Detection Methods**: We start by evaluating the existing Deep Fake detection techniques to understand their strengths and weaknesses.
2. **Developing an Integrated Algorithm**: Combining multiple approaches, we aim to create an algorithm that leverages both machine learning outputs and logical rules to enhance detection accuracy.
3. **Designing a Real-Time Processing System**: This involves creating a system capable of processing Deep Fake content in real-time, ensuring immediate detection and response.
4. **Creating a Testable Framework**: We will build a framework to test and validate our solutions rigorously.
5. **Planning for Product Development and Launch**: Finally, we will outline the steps for bringing our solution to market, ensuring it is scalable and effective.

## Model Selection and Evaluation

We have selected various models for tasks ranging from speech-to-text conversion to Deep Fake detection, each evaluated based on quality metrics such as word error rate and accuracy. Models like Rispolagi, Vithrian, and Hubert have shown promising results, while others require further evaluation.

## Our Approach

{{< figure src="https://images.siriusfrk.me/posts/2023-11-26-Junction-Budapest-2023/2.png" caption="" >}}

### Integrated Algorithm

Our integrated algorithm combines the strengths of machine learning with logical rules. This hybrid approach ensures precise and reasoned predictions, balancing advanced technology with clear decision-making processes.

### Real-Time Processing

The architecture of our solution is straightforward yet highly efficient. We use isolated model deployment in Docker containers alongside a custom scheduler. This setup enhances performance through model optimization for the Triton inference server, leveraging Triton's scheduling capabilities for better scalability and efficiency.

### Cost-Effective Operation

Our system operates cost-effectively, capable of handling a throughput of 20 to 80 users per day at minimal cost. With further optimization, we can increase efficiency and reduce expenses even more.

## Architecture

{{< figure src="https://images.siriusfrk.me/posts/2023-11-26-Junction-Budapest-2023/3.png" caption="" >}}

## Future Steps

Our next steps include:

1. **Enhancing System Architecture**: Continuously improving our system's architecture to handle growing volumes and complexities of Deep Fake content.
2. **Implementing Business Metrics**: Developing and analyzing business metrics to measure the real-world impact of our solution, ensuring it meets the needs of users and stakeholders.

## Conclusion

We are committed to providing an effective solution to the growing problem of Deep Fakes. Through our advanced detection techniques, integrated algorithms, and cost-effective operations, we aim to stay ahead of the curve and ensure reliable and efficient detection of Deep Fake content.

Thank you for your support. We are excited about the future and are dedicated to making a significant impact in the fight against Deep Fakes.

## Links
1. Presentation: https://docs.google.com/presentation/d/1N8eLYUQdY57h6amMj9RL-60tFmR4bwUjxBv8ixxLlPg/edit?usp=sharing
2. GitHub: https://github.com/siriusfreak/junction-budapest-2023
