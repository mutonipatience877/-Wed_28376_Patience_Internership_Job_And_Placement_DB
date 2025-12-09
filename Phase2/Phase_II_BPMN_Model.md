# Phase II – Business Process Model (BPMN)

![Business Process Model](/images/bpm_diagram.svg)

**Objective:**  
Visualize the end‑to‑end application, review, and placement process, showing how information flows between Students, the MIS System, Career Services, and Employers.

---

## Process Overview

1. **Student**  
   - Logs in, updates profile, searches opportunities, and submits applications.  
2. **MIS System**  
   - Validates profile completeness, runs matching algorithm, notifies students.  
3. **Career Services**  
   - Reviews algorithm‑flagged candidates, approves or rejects.  
4. **Employer**  
   - Reviews applications, schedules interviews, issues offers.  

---

## Key BPMN Elements

- **Start/End Events**: Student logs in → Placement Completed  
- **Tasks**: Profile update, Match algorithm, Review applications, Conduct interviews  
- **Gateways**: Profile completeness check, Application approval, Interview/Offer decisions  
- **Message Flows**: Notifications and application hand‑offs between lanes  
- **Data Objects**: Profile, Application, Match Results, Offer  

*This diagram was created in draw.io using BPMN 2.0 notation and swimlanes for clarity.*  
