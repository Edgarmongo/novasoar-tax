package com.novatax.novasoartax.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @program: novasoar-tax
 * @description:
 * @author: Timo
 * @create: 2026-09-18 23:56
 **/
@RestController
public class HelloWorldController {


    @GetMapping("/hello")
    public String hello(){
        return "hello world,hello k8s!";
    }
}
