package org.jeecg.common.util.security.entity;

import com.alibaba.fastjson.JSONObject;
import lombok.Data;

/**
 * @Description: SecurityResp
 * @author: liaoxingwang
 */
@Data
public class SecurityResp {
    private Boolean success;
    private JSONObject data;
}
