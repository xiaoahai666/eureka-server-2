#!/bin/bash

echo "=== Docker 网络深度诊断和修复 ==="

# 1. 检查网络状态
echo "1. 检查网络状态..."
docker network inspect eureka-cluster

# 2. 检查容器IP地址
echo ""
echo "2. 容器IP地址:"
for container in eureka-peer1 eureka-peer2 eureka-peer3; do
    ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container 2>/dev/null)
    if [ -n "$ip" ]; then
        echo "   $container: $ip"
    else
        echo "   $container: 未运行"
    fi
done

# 3. 测试容器间连通性
echo ""
echo "3. 测试容器间连通性..."
for src in eureka-peer1 eureka-peer2 eureka-peer3; do
    echo "--- $src 到其他节点 ---"
    for target in eureka-peer1 eureka-peer2 eureka-peer3; do
        if [ "$src" != "$target" ]; then
            # 获取目标端口
            port=$((8760 + $(echo $target | sed 's/eureka-peer//')))
            echo -n "  -> $target:$port: "
            # 使用 wget 或 curl 测试连通性
            docker exec $src sh -c "
                if command -v wget >/dev/null 2>&1; then
                    wget -q -O- --timeout=3 http://$target:$port/actuator/health >/dev/null 2>&1 && echo '✅' || echo '❌'
                elif command -v curl >/dev/null 2>&1; then
                    curl -s --connect-timeout 3 http://$target:$port/actuator/health >/dev/null 2>&1 && echo '✅' || echo '❌'
                else
                    echo '❌ (无网络工具)'
                fi
            " 2>/dev/null || echo "❌ (执行失败)"
        fi
    done
done

# 4. 检查DNS解析
echo ""
echo "4. 检查DNS解析..."
for container in eureka-peer1 eureka-peer2 eureka-peer3; do
    echo "--- $container DNS解析 ---"
    docker exec $container sh -c "
        if command -v nslookup >/dev/null 2>&1; then
            for host in eureka-peer1 eureka-peer2 eureka-peer3; do
                echo -n \"  $host: \"
                nslookup \$host 2>/dev/null | grep 'Address' | tail -1 | awk '{print \$2}' || echo '解析失败'
            done
        else
            echo '  nslookup 不可用'
        fi
    " 2>/dev/null || echo "  DNS检查失败"
done
