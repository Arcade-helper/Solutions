
# 🚀 Filtering Explores with LookML (GSP936)  
[![Subscribe](https://img.shields.io/badge/Subscribe-YouTube-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/@ArcadeHelper1418)  
**By [Arcade Helper](https://www.youtube.com/@ArcadeHelper1418)**

# Enable Development Mode

### Replace the Code of `training_ecommerce.model` with the Given below Code
```
connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

datagroup: training_ecommerce_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_ecommerce_default_datagroup

label: "E-Commerce Training"

explore: order_items {
  conditionally_filter: {
    filters: [created_date: "3 years"]
    unless: [users.id, users.state]
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
    relationship: many_to_one
  }
  join: event_session_funnel {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
    relationship: many_to_one
  }
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

```

## 🎉 You Did It!  
You've successfully completed the **Filtering Explores with LookML**!  

---

## 🌟 Stay Connected & Keep Growing

[![Like](https://img.shields.io/badge/Like-❤️-pink?style=for-the-badge)](https://www.youtube.com/@ArcadeHelper1418) 
[![Share](https://img.shields.io/badge/Share-🔁-blue?style=for-the-badge)](https://www.youtube.com/@ArcadeHelper1418) 
[![Subscribe](https://img.shields.io/badge/Subscribe-🔔-red?style=for-the-badge)](https://www.youtube.com/@ArcadeHelper1418)

---

> ✨ *Learning never stops — keep pushing boundaries!* ✨  
> 🛠️ *Follow [Arcade Helper](https://www.youtube.com/@ArcadeHelper1418) for more labs, tricks, and cloud adventures!*

---
