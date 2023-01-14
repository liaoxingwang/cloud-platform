package org.jeecg.modules.test.seata.account.controller;

import org.jeecg.modules.test.seata.account.service.SeataAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;

/**
 * @author liaoxingwang
 */
@RestController
@RequestMapping("/test/seata/account")
public class SeataAccountController {

    @Autowired
    private SeataAccountService accountService;

    @PostMapping("/reduceBalance")
    public void reduceBalance(Long userId, BigDecimal amount) {
        accountService.reduceBalance(userId, amount);
    }
}
