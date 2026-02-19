package com.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    // Handle both root "/" and empty "" paths
    @GetMapping(value = {"/", ""})
    public String home() {
        return "index"; // matches src/main/resources/templates/index.html
    }
}
